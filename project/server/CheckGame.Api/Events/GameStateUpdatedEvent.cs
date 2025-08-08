namespace CheckGame.Api.Events;

// Game state events
public record GameStateUpdatedEvent(string SessionId, object GameState, DateTime Timestamp = default)
{
    public DateTime Timestamp { get; init; } = Timestamp == default ? DateTime.UtcNow : Timestamp;
}
