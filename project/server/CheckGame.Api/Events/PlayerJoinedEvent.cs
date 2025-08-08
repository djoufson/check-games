namespace CheckGame.Api.Events;

// Connection events
public record PlayerJoinedEvent(string UserId, string UserName, string SessionId, DateTime Timestamp = default)
{
    public DateTime Timestamp { get; init; } = Timestamp == default ? DateTime.UtcNow : Timestamp;
}
