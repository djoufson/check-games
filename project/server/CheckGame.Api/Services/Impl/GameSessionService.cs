using CheckGame.Api.Contracts.Requests;
using CheckGame.Api.Contracts.Responses;
using CheckGame.Api.Hubs;
using CheckGame.Api.Options;
using CheckGame.Api.Persistence;
using CheckGame.Api.Persistence.Models;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace CheckGame.Api.Services.Impl;

public class GameSessionService : IGameSessionService
{
    private readonly AppDbContext _context;
    private readonly ILogger<GameSessionService> _logger;
    private readonly GameSessionOptions _gameSessionOptions;
    private readonly IHubContext<GameHub, IGameClient> _hubContext;
    private readonly IConnectionCacheService _connectionCacheService;

    public GameSessionService(
        AppDbContext context,
        ILogger<GameSessionService> logger,
        IOptions<GameSessionOptions> gameSessionOptions,
        IHubContext<GameHub, IGameClient> hubContext,
        IConnectionCacheService connectionCacheService)
    {
        _context = context;
        _logger = logger;
        _gameSessionOptions = gameSessionOptions.Value;
        _hubContext = hubContext;
        _connectionCacheService = connectionCacheService;
    }

    public async Task<CreateSessionResponse> CreateSessionAsync(string createdByUserId, CreateGameSessionRequest request)
    {
        // Use configured defaults if not specified, enforce limits
        var maxPlayers = request.MaxPlayersLimit > 0 ? request.MaxPlayersLimit : Math.Max(_gameSessionOptions.MinPlayersLimit, _gameSessionOptions.MaxPlayersLimit);

        GameSession session;
        var maxRetries = 3;

        // Retry in case of code collision (very unlikely but possible)
        for (var retry = 0; retry < maxRetries; retry++)
        {
            try
            {
                var userName = await _context.Users
                    .AsNoTracking()
                    .Where(u => u.Id == createdByUserId)
                    .Select(u => u.UserName)
                    .FirstOrDefaultAsync();

                session = GameSession.Create(userName ?? createdByUserId, createdByUserId, maxPlayers);
                _context.GameSessions.Add(session);
                await _context.SaveChangesAsync();

                _logger.LogInformation("Created game session {SessionId} by user {UserId}", session.Id, createdByUserId);

                // Automatically add the session creator to the SignalR group for real-time updates
                await AddUserToSessionGroupAsync(createdByUserId, session.Id);

                var sessionResponse = await MapToResponseAsync(session);
                var shareableLink = $"checkgames://join/{session.Code}";

                return new CreateSessionResponse(sessionResponse, shareableLink);
            }
            catch (Exception ex) when (ex.Message.Contains("IX_GameSessions_Code") && retry < maxRetries - 1)
            {
                // Code collision, retry with a new code
                _logger.LogWarning("Session code collision occurred, retrying... (attempt {Retry})", retry + 1);
                _context.ChangeTracker.Clear(); // Clear the failed entity from tracking
            }
        }

        // If we get here, all retries failed
        throw new InvalidOperationException("Failed to create session after multiple attempts due to code collisions");
    }

    public async Task<JoinSessionResponse?> JoinSessionAsync(string? userId, string sessionCode, JoinGameSessionRequest request)
    {
        var session = await _context.GameSessions
            .Include(s => s.CreatedByUser)
            .FirstOrDefaultAsync(s => s.Code == sessionCode);

        if (session == null || !session.CanJoin())
        {
            return null;
        }

        // Generate player name using configured formats
        string playerName;
        if (!string.IsNullOrEmpty(request.PlayerName))
        {
            playerName = request.PlayerName;
        }
        else if (!string.IsNullOrEmpty(userId))
        {
            playerName = $"Player_{userId}";
        }
        else
        {
            playerName = $"Guest_{Guid.NewGuid().ToString("N")[..8]}";
        }

        // Ensure unique player name in session
        var originalPlayerName = playerName;
        var counter = 1;
        while (session.Players.Contains(playerName))
        {
            playerName = $"{originalPlayerName}_{counter}";
            counter++;
        }

        if (!session.AddPlayer(playerName))
        {
            return null;
        }

        _context.GameSessions.Update(session);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Player {PlayerName} joined session {SessionId}", playerName, session.Id);

        // Automatically add the user to the SignalR group for real-time updates if authenticated
        if (!string.IsNullOrEmpty(userId))
        {
            await AddUserToSessionGroupAsync(userId, session.Id);
        }

        var sessionResponse = await MapToResponseAsync(session);
        return new JoinSessionResponse(session.Id, playerName, sessionResponse);
    }

    public async Task<bool> LeaveSessionAsync(string sessionId, string playerName)
    {
        var session = await _context.GameSessions.FirstOrDefaultAsync(s => s.Id == sessionId);

        if (session == null)
        {
            return false;
        }

        if (!session.RemovePlayer(playerName))
        {
            return false;
        }

        // If the session is empty, we could consider marking it as cancelled
        var remainingPlayers = session.Players;
        if (remainingPlayers.Count == 0)
        {
            _context.GameSessions.Remove(session);
        }
        else
        {
            _context.GameSessions.Update(session);
        }

        await _context.SaveChangesAsync();

        _logger.LogInformation("Player {PlayerName} left session {SessionId}", playerName, sessionId);
        return true;
    }

    public async Task<GameSessionResponse?> GetSessionAsync(string sessionId)
    {
        var session = await _context.GameSessions
            .Include(s => s.CreatedByUser)
            .FirstOrDefaultAsync(s => s.Id == sessionId);

        if (session == null)
        {
            return null;
        }

        return await MapToResponseAsync(session);
    }

    public async Task<GameSessionListResponse> GetActiveSessionsAsync(int page = 1, int pageSize = 20)
    {
        var query = _context.GameSessions
            .Include(s => s.CreatedByUser)
            .Where(s => s.Status == GameSessionStatus.WaitingForPlayers)
            .OrderByDescending(s => s.CreatedAt);

        var totalCount = await query.CountAsync();
        var sessions = await query
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();

        var sessionResponses = new List<GameSessionResponse>();
        foreach (var session in sessions)
        {
            sessionResponses.Add(await MapToResponseAsync(session));
        }

        return new GameSessionListResponse(
            [.. sessionResponses],
            totalCount,
            page,
            pageSize);
    }

    public async Task<GameSessionListResponse> GetUserSessionsAsync(string userId, int page = 1, int pageSize = 20)
    {
        var query = _context.GameSessions
            .Include(s => s.CreatedByUser)
            .Where(s => s.CreatedByUserId == userId)
            .OrderByDescending(s => s.CreatedAt);

        var totalCount = await query.CountAsync();
        var sessions = await query
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();

        var sessionResponses = new List<GameSessionResponse>();
        foreach (var session in sessions)
        {
            sessionResponses.Add(await MapToResponseAsync(session));
        }

        return new GameSessionListResponse(
            [.. sessionResponses],
            totalCount,
            page,
            pageSize);
    }

    public async Task<bool> StartGameAsync(string sessionId, string userId)
    {
        var session = await _context.GameSessions.FirstOrDefaultAsync(s => s.Id == sessionId);

        if (session == null || !session.IsCreator(userId) || session.Players.Count < 2)
        {
            return false;
        }

        session.StartGame();
        _context.GameSessions.Update(session);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Started game session {SessionId}", sessionId);
        return true;
    }

    public async Task<bool> EndGameAsync(string sessionId, string userId)
    {
        var session = await _context.GameSessions.FirstOrDefaultAsync(s => s.Id == sessionId);

        if (session == null || !session.IsCreator(userId))
        {
            return false;
        }

        session.EndGame();
        _context.GameSessions.Update(session);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Ended game session {SessionId}", sessionId);
        return true;
    }

    private async Task<GameSessionResponse> MapToResponseAsync(GameSession session)
    {
        // Ensure the related user is loaded
        if (session.CreatedByUser == null)
        {
            await _context.Entry(session)
                .Reference(s => s.CreatedByUser)
                .LoadAsync();
        }

        return new GameSessionResponse(
            session.Id,
            session.Code,
            session.Name,
            session.MaxPlayers,
            session.Players.Count,
            session.Status,
            [.. session.Players],
            session.CreatedByUserId,
            session.CreatedByUser?.UserName,
            session.CreatedAt,
            session.StartedAt,
            session.EndedAt,
            session.CanJoin(),
            session.IsFull());
    }

    /// <summary>
    /// Adds an authenticated user to a SignalR session group using their active connections
    /// </summary>
    private async Task AddUserToSessionGroupAsync(string userId, string sessionId)
    {
        try
        {
            // Get all active connections for the authenticated user
            var userConnections = await _connectionCacheService.GetConnectionsAsync(userId);

            if (userConnections.Count == 0)
            {
                _logger.LogDebug("No active connections found for user {UserId} to add to session {SessionId}", userId, sessionId);
                return;
            }

            // Add each connection to the SignalR session group
            var groupName = $"GameSession_{sessionId}";
            foreach (var connectionId in userConnections)
            {
                await _hubContext.Groups.AddToGroupAsync(connectionId, groupName);
                _logger.LogDebug("Added connection {ConnectionId} for user {UserId} to SignalR group {GroupName}",
                    connectionId, userId, groupName);
            }

            _logger.LogInformation("Added {ConnectionCount} connections for user {UserId} to session group {SessionId}",
                userConnections.Count, userId, sessionId);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error adding user {UserId} connections to session group {SessionId}", userId, sessionId);
        }
    }
}