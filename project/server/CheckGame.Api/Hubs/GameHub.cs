using CheckGame.Api.Events;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using System.Security.Claims;

namespace CheckGame.Api.Hubs;

[Authorize]
public class GameHub : Hub<IGameClient>, IGameServer
{
    private readonly ILogger<GameHub> _logger;

    public GameHub(ILogger<GameHub> logger)
    {
        _logger = logger;
    }

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
        
        // Leave all game sessions when disconnected
        await LeaveAllGames();
        
        await base.OnDisconnectedAsync(exception);
    }

    // Game session management
    public async Task JoinGameSession(string sessionId)
    {
        var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        var userName = Context.User?.FindFirst(ClaimTypes.Name)?.Value;

        if (string.IsNullOrEmpty(userId) || string.IsNullOrEmpty(sessionId))
        {
            await Clients.Caller.Error("Invalid session or user data");
            return;
        }

        await Groups.AddToGroupAsync(Context.ConnectionId, $"GameSession_{sessionId}");
        
        _logger.LogInformation("User {UserName} ({UserId}) joined game session {SessionId}", 
            userName, userId, sessionId);

        // Notify other players in the session
        var playerJoinedEvent = new PlayerJoinedEvent(userId, userName ?? "Unknown", sessionId);
        await Clients.Group($"GameSession_{sessionId}").PlayerJoined(playerJoinedEvent);
    }

    public async Task LeaveGameSession(string sessionId)
    {
        var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        var userName = Context.User?.FindFirst(ClaimTypes.Name)?.Value;

        if (string.IsNullOrEmpty(userId) || string.IsNullOrEmpty(sessionId))
        {
            await Clients.Caller.Error("Invalid session or user data");
            return;
        }

        await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"GameSession_{sessionId}");
        
        _logger.LogInformation("User {UserName} ({UserId}) left game session {SessionId}", 
            userName, userId, sessionId);

        // Notify other players in the session
        var playerLeftEvent = new PlayerLeftEvent(userId, userName ?? "Unknown", sessionId);
        await Clients.Group($"GameSession_{sessionId}").PlayerLeft(playerLeftEvent);
    }

    // Game actions
    public async Task PlayCard(string sessionId, object cardData)
    {
        var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        var userName = Context.User?.FindFirst(ClaimTypes.Name)?.Value;

        if (string.IsNullOrEmpty(userId) || string.IsNullOrEmpty(sessionId))
        {
            await Clients.Caller.Error("Invalid session or user data");
            return;
        }

        _logger.LogInformation("User {UserName} ({UserId}) played card in session {SessionId}", 
            userName, userId, sessionId);

        // Broadcast card play to all players in the session
        var cardPlayedEvent = new CardPlayedEvent(userId, userName ?? "Unknown", sessionId, cardData);
        await Clients.Group($"GameSession_{sessionId}").CardPlayed(cardPlayedEvent);
    }

    public async Task DrawCard(string sessionId)
    {
        var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        var userName = Context.User?.FindFirst(ClaimTypes.Name)?.Value;

        if (string.IsNullOrEmpty(userId) || string.IsNullOrEmpty(sessionId))
        {
            await Clients.Caller.Error("Invalid session or user data");
            return;
        }

        _logger.LogInformation("User {UserName} ({UserId}) drew card in session {SessionId}", 
            userName, userId, sessionId);

        // Broadcast card draw to all players in the session (default to 1 card drawn)
        var cardDrawnEvent = new CardDrawnEvent(userId, userName ?? "Unknown", sessionId, CardCount: 1);
        await Clients.Group($"GameSession_{sessionId}").CardDrawn(cardDrawnEvent);
    }

    public async Task SendGameMessage(string sessionId, string message)
    {
        var userId = Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        var userName = Context.User?.FindFirst(ClaimTypes.Name)?.Value;

        if (string.IsNullOrEmpty(userId) || string.IsNullOrEmpty(sessionId) || string.IsNullOrEmpty(message))
        {
            await Clients.Caller.Error("Invalid message data");
            return;
        }

        // Broadcast message to all players in the session
        var gameMessageEvent = new GameMessageEvent(userId, userName ?? "Unknown", sessionId, message);
        await Clients.Group($"GameSession_{sessionId}").GameMessage(gameMessageEvent);
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

    // Helper method to leave all games when disconnecting
    private async Task LeaveAllGames()
    {
        // In a real implementation, you would track which sessions the user is in
        // and remove them from those groups. For now, this is a placeholder.
        await Task.CompletedTask;
    }
}