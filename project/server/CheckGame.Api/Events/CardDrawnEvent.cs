namespace CheckGame.Api.Events;

public record CardDrawnEvent(string UserId, string UserName, string SessionId, int CardCount, DateTime Timestamp = default)
{
    public DateTime Timestamp { get; init; } = Timestamp == default ? DateTime.UtcNow : Timestamp;
}
