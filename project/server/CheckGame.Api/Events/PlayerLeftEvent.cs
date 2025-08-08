namespace CheckGame.Api.Events;

public record PlayerLeftEvent(string UserId, string UserName, string SessionId, DateTime Timestamp = default)
{
    public DateTime Timestamp { get; init; } = Timestamp == default ? DateTime.UtcNow : Timestamp;
}
