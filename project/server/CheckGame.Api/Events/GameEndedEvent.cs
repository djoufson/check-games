namespace CheckGame.Api.Events;

public record GameEndedEvent(string SessionId, string WinnerId, string[] PlayerRanking, DateTime Timestamp = default)
{
    public DateTime Timestamp { get; init; } = Timestamp == default ? DateTime.UtcNow : Timestamp;
}
