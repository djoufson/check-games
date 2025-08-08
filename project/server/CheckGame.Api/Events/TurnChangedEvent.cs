namespace CheckGame.Api.Events;

public record TurnChangedEvent(string SessionId, string CurrentPlayerId, string NextPlayerId, DateTime Timestamp = default)
{
    public DateTime Timestamp { get; init; } = Timestamp == default ? DateTime.UtcNow : Timestamp;
}