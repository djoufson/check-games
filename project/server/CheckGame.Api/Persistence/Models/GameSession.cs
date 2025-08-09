using System.Text.Json;

namespace CheckGame.Api.Persistence.Models;

public class GameSession
{
    public string Id { get; private set; } = string.Empty;

    public string CreatedByUserId { get; private set; } = string.Empty;

    public User CreatedByUser { get; private set; }

    public string Name { get; private set; } = string.Empty;

    public int MaxPlayers { get; private set; }

    public GameSessionStatus Status { get; private set; }

    /// <summary>
    /// Serialized list of player IDs (names) currently in the session
    /// </summary>
    public List<string> Players { get; private set; }

    public DateTime CreatedAt { get; private set; }

    public DateTime? StartedAt { get; private set; }

    public DateTime? EndedAt { get; private set; }

#pragma warning disable CS8618 // Non-nullable field must contain a non-null value when exiting constructor. Consider adding the 'required' modifier or declaring as nullable.
    private GameSession() { } // EF Core constructor
#pragma warning restore CS8618 // Non-nullable field must contain a non-null value when exiting constructor. Consider adding the 'required' modifier or declaring as nullable.

    public static GameSession Create(
        string createdByUserId,
        string name,
        int maxPlayers = 6)
    {
        var session = new GameSession
        {
            Id = Guid.NewGuid().ToString(),
            CreatedByUserId = createdByUserId,
            Name = name,
            Status = GameSessionStatus.WaitingForPlayers,
            CreatedAt = DateTime.UtcNow,
            MaxPlayers = Math.Max(2, Math.Min(6, maxPlayers)) // Enforce 2-6 players
        };

        // Add the creator as the first player
        var creatorPlayerName = $"Player_{createdByUserId}";
        session.Players = [creatorPlayerName ];

        return session;
    }

    public bool AddPlayer(string playerName)
    {
        // Check if player already exists or session is full
        if (Players.Contains(playerName) || Players.Count >= MaxPlayers)
        {
            return false;
        }

        Players.Add(playerName);
        return true;
    }

    public bool RemovePlayer(string playerName)
    {
        if (Players.Remove(playerName))
        {
            return true;
        }

        return false;
    }

    public void StartGame()
    {
        if (Status == GameSessionStatus.WaitingForPlayers && Players.Count >= 2)
        {
            Status = GameSessionStatus.InProgress;
            StartedAt = DateTime.UtcNow;
        }
    }

    public void EndGame()
    {
        if (Status == GameSessionStatus.InProgress)
        {
            Status = GameSessionStatus.Completed;
            EndedAt = DateTime.UtcNow;
        }
    }

    public bool IsCreator(string userId) => CreatedByUserId == userId;

    public bool IsFull() => Players.Count >= MaxPlayers;

    public bool CanJoin() => Status == GameSessionStatus.WaitingForPlayers && !IsFull();
}

public enum GameSessionStatus
{
    WaitingForPlayers = 0,
    InProgress = 1,
    Completed = 2,
    Cancelled = 3
}
