namespace CheckGame.Api.Events;

// Game action events
public record CardPlayedEvent(string UserId, string UserName, string SessionId, object Card, DateTime Timestamp = default)
{
    public DateTime Timestamp { get; init; } = Timestamp == default ? DateTime.UtcNow : Timestamp;
}
