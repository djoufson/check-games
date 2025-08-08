namespace CheckGame.Api.Events;

public record GameStartedEvent(string SessionId, string[] PlayerIds, DateTime Timestamp = default)
{
    public DateTime Timestamp { get; init; } = Timestamp == default ? DateTime.UtcNow : Timestamp;
}
