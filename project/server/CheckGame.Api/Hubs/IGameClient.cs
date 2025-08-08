using CheckGame.Api.Events;

namespace CheckGame.Api.Hubs;

/// <summary>
/// Defines methods that can be called on SignalR clients
/// </summary>
public interface IGameClient
{
    // Connection events
    Task PlayerJoined(PlayerJoinedEvent playerJoined);
    Task PlayerLeft(PlayerLeftEvent playerLeft);

    // Game action events
    Task CardPlayed(CardPlayedEvent cardPlayed);
    Task CardDrawn(CardDrawnEvent cardDrawn);
    Task SuitChanged(SuitChangedEvent suitChanged);

    // Game state events
    Task GameStateUpdated(GameStateUpdatedEvent gameStateUpdated);
    Task GameStarted(GameStartedEvent gameStarted);
    Task GameEnded(GameEndedEvent gameEnded);
    Task TurnChanged(TurnChangedEvent turnChanged);

    // Communication events
    Task GameMessage(GameMessageEvent gameMessage);

    // Error handling
    Task Error(string message);
}