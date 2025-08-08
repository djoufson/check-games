namespace CheckGame.Api.Events;

public record SuitChangedEvent(string UserId, string UserName, string SessionId, string NewSuit, DateTime Timestamp = default)
{
    public DateTime Timestamp { get; init; } = Timestamp == default ? DateTime.UtcNow : Timestamp;
}
