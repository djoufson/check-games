using CheckGame.Api.Contracts.Requests;
using CheckGame.Api.Events;
using CheckGame.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using System.Security.Claims;

namespace CheckGame.Api.Hubs;

public class GameHub(ILogger<GameHub> logger, IGameSessionService gameSessionService) : Hub<IGameClient>, IGameServer
{
    private readonly ILogger<GameHub> _logger = logger;
    private readonly IGameSessionService _gameSessionService = gameSessionService;

    public override async Task OnConnectedAsync()
    {
        var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        var userName = Context.User?.FindFirst(ClaimTypes.Name)?.Value;

        _logger.LogInformation("User {UserName} ({UserId}) connected to GameHub", userName, userId);

        await base.OnConnectedAsync();
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        var userName = Context.User?.FindFirst(ClaimTypes.Name)?.Value;

        _logger.LogInformation("User {UserName} ({UserId}) disconnected from GameHub", userName, userId);

        // Note: In a production implementation, you would track which sessions 
        // the user is in and automatically leave them here.
        // For now, clients should explicitly call LeaveGameSession before disconnecting.

        await base.OnDisconnectedAsync(exception);
    }

    // Game session management (SignalR only - assumes user already joined via REST API)
    public async Task JoinGameSession(string sessionId, string? playerName = null)
    {
        var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        var userName = Context.User?.FindFirst(ClaimTypes.Name)?.Value;

        if (string.IsNullOrEmpty(sessionId))
        {
            await Clients.Caller.Error("Invalid session ID");
            return;
        }

        try
        {
            // Verify the session exists
            var session = await _gameSessionService.GetSessionAsync(sessionId);
            if (session == null)
            {
                await Clients.Caller.Error("Session not found");
                return;
            }

            // Use provided playerName or fallback to userName or generate one
            var playerNameToUse = playerName ?? userName ?? $"Player_{Guid.NewGuid().ToString()[..8]}";

            // Add to SignalR group for real-time communication
            await Groups.AddToGroupAsync(Context.ConnectionId, $"GameSession_{sessionId}");

            _logger.LogInformation("Player {PlayerName} (UserId: {UserId}) connected to SignalR for session {SessionId}",
                playerNameToUse, userId, sessionId);

            // Notify other players in the session that someone connected
            var playerJoinedEvent = new PlayerJoinedEvent(userId ?? "anonymous", playerNameToUse, sessionId);
            await Clients.Group($"GameSession_{sessionId}").PlayerJoined(playerJoinedEvent);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error connecting to SignalR session {SessionId} for user {UserId}", sessionId, userId);
            await Clients.Caller.Error("An error occurred while connecting to the session");
        }
    }

    public async Task LeaveGameSession(string sessionId)
    {
        var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        var userName = Context.User?.FindFirst(ClaimTypes.Name)?.Value;

        if (string.IsNullOrEmpty(sessionId))
        {
            await Clients.Caller.Error("Invalid session ID");
            return;
        }

        try
        {
            // Use provided userName or generate fallback for the notification
            var playerNameForNotification = userName ?? $"Player_{Guid.NewGuid().ToString()[..8]}";

            // Remove from SignalR group
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"GameSession_{sessionId}");

            _logger.LogInformation("Player {PlayerName} (UserId: {UserId}) disconnected from SignalR session {SessionId}",
                playerNameForNotification, userId, sessionId);

            // Notify other players that someone disconnected from SignalR
            var playerLeftEvent = new PlayerLeftEvent(userId ?? "anonymous", playerNameForNotification, sessionId);
            await Clients.Group($"GameSession_{sessionId}").PlayerLeft(playerLeftEvent);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error disconnecting from SignalR session {SessionId} for user {UserId}", sessionId, userId);
            await Clients.Caller.Error("An error occurred while disconnecting from the session");
        }
    }

    // Game actions
    public async Task PlayCard(string sessionId, object cardData)
    {
        var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        var userName = Context.User?.FindFirst(ClaimTypes.Name)?.Value;

        if (string.IsNullOrEmpty(sessionId))
        {
            await Clients.Caller.Error("Invalid session ID");
            return;
        }

        try
        {
            // TODO: Integrate with game engine to validate card play
            // For now, just validate that the session exists
            var session = await _gameSessionService.GetSessionAsync(sessionId);
            if (session == null)
            {
                await Clients.Caller.Error("Session not found");
                return;
            }

            var playerName = userName ?? $"Player_{Guid.NewGuid().ToString()[..8]}";
            
            _logger.LogInformation("Player {PlayerName} (UserId: {UserId}) played card in session {SessionId}",
                playerName, userId, sessionId);

            // Broadcast card play to all players in the session
            var cardPlayedEvent = new CardPlayedEvent(userId ?? "anonymous", playerName, sessionId, cardData);
            await Clients.Group($"GameSession_{sessionId}").CardPlayed(cardPlayedEvent);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error playing card in session {SessionId} for user {UserId}", sessionId, userId);
            await Clients.Caller.Error("An error occurred while playing the card");
        }
    }

    public async Task DrawCard(string sessionId)
    {
        var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        var userName = Context.User?.FindFirst(ClaimTypes.Name)?.Value;

        if (string.IsNullOrEmpty(sessionId))
        {
            await Clients.Caller.Error("Invalid session ID");
            return;
        }

        try
        {
            // TODO: Integrate with game engine to handle card drawing
            // For now, just validate that the session exists
            var session = await _gameSessionService.GetSessionAsync(sessionId);
            if (session == null)
            {
                await Clients.Caller.Error("Session not found");
                return;
            }

            var playerName = userName ?? $"Player_{Guid.NewGuid().ToString()[..8]}";
            
            _logger.LogInformation("Player {PlayerName} (UserId: {UserId}) drew card in session {SessionId}",
                playerName, userId, sessionId);

            // Broadcast card draw to all players in the session (default to 1 card drawn)
            var cardDrawnEvent = new CardDrawnEvent(userId ?? "anonymous", playerName, sessionId, CardCount: 1);
            await Clients.Group($"GameSession_{sessionId}").CardDrawn(cardDrawnEvent);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error drawing card in session {SessionId} for user {UserId}", sessionId, userId);
            await Clients.Caller.Error("An error occurred while drawing the card");
        }
    }

    public async Task SendGameMessage(string sessionId, string message)
    {
        var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        var userName = Context.User?.FindFirst(ClaimTypes.Name)?.Value;

        if (string.IsNullOrEmpty(sessionId) || string.IsNullOrEmpty(message))
        {
            await Clients.Caller.Error("Invalid message data");
            return;
        }

        try
        {
            // Validate that the session exists
            var session = await _gameSessionService.GetSessionAsync(sessionId);
            if (session == null)
            {
                await Clients.Caller.Error("Session not found");
                return;
            }

            var playerName = userName ?? $"Player_{Guid.NewGuid().ToString()[..8]}";
            
            // Broadcast message to all players in the session
            var gameMessageEvent = new GameMessageEvent(userId ?? "anonymous", playerName, sessionId, message);
            await Clients.Group($"GameSession_{sessionId}").GameMessage(gameMessageEvent);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error sending message in session {SessionId} for user {UserId}", sessionId, userId);
            await Clients.Caller.Error("An error occurred while sending the message");
        }
    }

    // Additional game methods from IGameServer interface
    public async Task ChangeSuit(string sessionId, string newSuit)
    {
        var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        var userName = Context.User?.FindFirst(ClaimTypes.Name)?.Value;

        if (string.IsNullOrEmpty(userId) || string.IsNullOrEmpty(sessionId) || string.IsNullOrEmpty(newSuit))
        {
            await Clients.Caller.Error("Invalid suit change data");
            return;
        }

        _logger.LogInformation("User {UserName} ({UserId}) changed suit to {NewSuit} in session {SessionId}",
            userName, userId, newSuit, sessionId);

        // TODO: Integrate with game engine to validate and apply suit change
        // For now, just notify clients of the change
        var suitChangedEvent = new SuitChangedEvent(userId, userName ?? "Unknown", sessionId, newSuit);
        await Clients.Group($"GameSession_{sessionId}").SuitChanged(suitChangedEvent);
    }

    public async Task RequestGameState(string sessionId)
    {
        var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        if (string.IsNullOrEmpty(userId) || string.IsNullOrEmpty(sessionId))
        {
            await Clients.Caller.Error("Invalid session or user data");
            return;
        }

        // TODO: Integrate with game engine to get actual game state
        // For now, send a placeholder response
        var gameStateUpdateEvent = new GameStateUpdatedEvent(sessionId, new { Message = "Game state requested" });
        await Clients.Caller.GameStateUpdated(gameStateUpdateEvent);
    }

}