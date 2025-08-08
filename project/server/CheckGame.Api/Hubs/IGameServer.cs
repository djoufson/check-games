namespace CheckGame.Api.Hubs;

/// <summary>
/// Defines methods that clients can call on the SignalR hub
/// </summary>
public interface IGameServer
{
    // Session management
    Task JoinGameSession(string sessionId);
    Task LeaveGameSession(string sessionId);
    
    // Game actions
    Task PlayCard(string sessionId, object cardData);
    Task DrawCard(string sessionId);
    Task ChangeSuit(string sessionId, string newSuit);
    
    // Communication
    Task SendGameMessage(string sessionId, string message);
    
    // Game state requests
    Task RequestGameState(string sessionId);
}