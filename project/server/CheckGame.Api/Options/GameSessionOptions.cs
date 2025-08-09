namespace CheckGame.Api.Options;

public class GameSessionOptions
{
    public const string SectionName = "GameSession";

    /// <summary>
    /// Maximum number of players allowed per session
    /// </summary>
    public int MaxPlayersLimit { get; init; } = 6;

    /// <summary>
    /// Minimum number of players allowed per session
    /// </summary>
    public int MinPlayersLimit { get; init; } = 2;
}