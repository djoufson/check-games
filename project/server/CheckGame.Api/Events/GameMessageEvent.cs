namespace CheckGame.Api.Events;

// Communication events
public record GameMessageEvent(string UserId, string UserName, string SessionId, string Message, DateTime Timestamp = default)
{
    public DateTime Timestamp { get; init; } = Timestamp == default ? DateTime.UtcNow : Timestamp;
}
