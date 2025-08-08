# In-Memory Game State Management

## Overview
High-performance game state management using Redis as the primary storage with .NET's memory-optimized data structures. Zero database I/O during active gameplay for maximum responsiveness.

## Architecture Philosophy

### Performance-First Approach
- **In-Memory Primary Storage**: Redis for authoritative game state
- **Zero Database I/O**: No database calls during active gameplay
- **Memory Optimization**: Span<T>, Memory<T>, and object pooling
- **Minimal Serialization**: Efficient binary serialization where possible
- **State Synchronization**: Event-driven updates to all clients

### Data Flow
```
1. Game starts → State created in Redis
2. Player action → State updated in Redis
3. State change → Broadcast to all players via SignalR
4. Game ends → Summary persisted to database
```

## Core Game State Models

### Game State Structure
```csharp
public record GameState
{
    public required Guid GameId { get; init; }
    public required Guid SessionId { get; init; }
    public required int GameNumber { get; init; }
    public GameStatus Status { get; init; } = GameStatus.Waiting;
    
    // Player management
    public required List<GamePlayer> Players { get; init; } = [];
    public required Guid CurrentPlayerId { get; init; }
    public int TurnDirection { get; init; } = 1; // 1 = clockwise, -1 = counter-clockwise
    public required int[] PlayOrder { get; init; } // Array of player indexes for performance
    
    // Card state (using memory-efficient structures)
    public required Card[] DrawPile { get; init; }
    public required Card[] DiscardPile { get; init; }
    public required Card CurrentCard { get; init; }
    
    // Special effects
    public int AttackStack { get; init; } = 0;
    public CardSuit? ChosenSuit { get; init; }
    public bool SkipNextPlayer { get; init; } = false;
    
    // Metadata
    public DateTime CreatedAt { get; init; } = DateTime.UtcNow;
    public DateTime LastUpdated { get; init; } = DateTime.UtcNow;
    public long Version { get; init; } = 1; // For optimistic locking
    
    // Performance optimizations
    public int DrawPileCount => DrawPile.Length;
    public int DiscardPileCount => DiscardPile.Length;
    public int ActivePlayerCount => Players.Count(p => !p.IsEliminated);
}

public record GamePlayer
{
    public required Guid Id { get; init; }
    public required string Username { get; init; }
    public required Card[] Hand { get; init; } // Fixed array for performance
    public int HandCount => Hand.Count(c => c != Card.Empty); // Count non-empty slots
    public int PlayOrder { get; init; }
    public bool IsEliminated { get; init; } = false;
    public DateTime? EliminatedAt { get; init; }
}

// Memory-optimized card structure
public readonly record struct Card
{
    public readonly CardSuit Suit;
    public readonly CardRank Rank;
    public readonly CardColor Color;
    public readonly int Id; // For tracking specific card instances
    
    public Card(CardSuit suit, CardRank rank, int id = 0)
    {
        Suit = suit;
        Rank = rank;
        Color = suit is CardSuit.Hearts or CardSuit.Diamonds ? CardColor.Red : CardColor.Black;
        Id = id;
    }
    
    public static readonly Card Empty = new(CardSuit.Spades, CardRank.Ace, -1);
    public bool IsEmpty => Id == -1;
}
```

### Session State
```csharp
public record SessionState
{
    public required Guid SessionId { get; init; }
    public required string? Name { get; init; }
    public required string JoinCode { get; init; }
    public SessionStatus Status { get; init; } = SessionStatus.Waiting;
    
    // Player management
    public required List<SessionPlayer> Players { get; init; } = [];
    public int MaxPlayers { get; init; } = 4;
    public int CurrentPlayerCount => Players.Count(p => p.IsActive);
    
    // Tournament state
    public int GamesPlayed { get; init; } = 0;
    public required List<Guid> EliminatedPlayers { get; init; } = [];
    public Guid? CurrentGameId { get; init; }
    
    // Metadata
    public required Guid CreatedBy { get; init; }
    public DateTime CreatedAt { get; init; } = DateTime.UtcNow;
    public DateTime? StartedAt { get; init; }
    public DateTime LastActivity { get; init; } = DateTime.UtcNow;
}

public record SessionPlayer
{
    public required Guid Id { get; init; }
    public required string Username { get; init; }
    public bool IsAnonymous { get; init; } = false;
    public bool IsActive { get; init; } = true;
    public DateTime JoinedAt { get; init; } = DateTime.UtcNow;
    public string? ConnectionId { get; init; } // For SignalR targeting
}
```

## Redis Storage Implementation

### Game State Service
```csharp
public interface IGameStateService
{
    Task<GameState?> GetGameStateAsync(Guid gameId);
    Task<bool> SetGameStateAsync(GameState gameState);
    Task<bool> DeleteGameStateAsync(Guid gameId);
    Task<GameActionResult> PlayCardAsync(Guid sessionId, Guid playerId, Card card, CardSuit? chosenSuit = null);
    Task<GameActionResult> DrawCardAsync(Guid sessionId, Guid playerId);
    Task<GameState> StartNewGameAsync(Guid sessionId, List<SessionPlayer> players);
}

public class RedisGameStateService : IGameStateService
{
    private readonly IDatabase _database;
    private readonly IGameEngine _gameEngine;
    private readonly ILogger<RedisGameStateService> _logger;
    private readonly IMemoryPool<byte> _memoryPool;

    public RedisGameStateService(
        IConnectionMultiplexer redis, 
        IGameEngine gameEngine,
        ILogger<RedisGameStateService> logger,
        IMemoryPool<byte> memoryPool)
    {
        _database = redis.GetDatabase();
        _gameEngine = gameEngine;
        _logger = logger;
        _memoryPool = memoryPool;
    }

    public async Task<GameState?> GetGameStateAsync(Guid gameId)
    {
        try
        {
            var key = GetGameStateKey(gameId);
            var data = await _database.HashGetAllAsync(key);
            
            if (data.Length == 0) return null;
            
            return DeserializeGameState(data);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to get game state for game {GameId}", gameId);
            return null;
        }
    }

    public async Task<bool> SetGameStateAsync(GameState gameState)
    {
        try
        {
            var key = GetGameStateKey(gameState.GameId);
            var serializedData = SerializeGameState(gameState);
            
            // Use Redis hash for structured storage
            var hash = new HashEntry[]
            {
                new("data", serializedData),
                new("version", gameState.Version),
                new("lastUpdated", gameState.LastUpdated.ToBinary()),
                new("sessionId", gameState.SessionId.ToString())
            };
            
            await _database.HashSetAsync(key, hash);
            await _database.KeyExpireAsync(key, TimeSpan.FromHours(24)); // Auto-cleanup
            
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to set game state for game {GameId}", gameState.GameId);
            return false;
        }
    }

    public async Task<GameActionResult> PlayCardAsync(Guid sessionId, Guid playerId, Card card, CardSuit? chosenSuit = null)
    {
        var lockKey = GetGameStateLockKey(sessionId);
        var lockValue = Guid.NewGuid().ToString();
        var lockDuration = TimeSpan.FromSeconds(5);
        
        // Distributed lock for concurrent action handling
        if (!await AcquireLockAsync(lockKey, lockValue, lockDuration))
        {
            return GameActionResult.Failure("GAME_LOCKED", "Game is being updated by another player");
        }

        try
        {
            // Get current game state
            var currentGameId = await GetCurrentGameIdAsync(sessionId);
            if (!currentGameId.HasValue)
            {
                return GameActionResult.Failure("NO_ACTIVE_GAME", "No active game in session");
            }

            var gameState = await GetGameStateAsync(currentGameId.Value);
            if (gameState == null)
            {
                return GameActionResult.Failure("GAME_NOT_FOUND", "Game state not found");
            }

            // Process the card play using the game engine
            var result = _gameEngine.ProcessCardPlay(gameState, playerId, card, chosenSuit);
            if (!result.IsSuccess)
            {
                return result;
            }

            // Update game state in Redis
            await SetGameStateAsync(result.NewGameState!);
            
            return result;
        }
        finally
        {
            await ReleaseLockAsync(lockKey, lockValue);
        }
    }

    // Memory-efficient serialization
    private byte[] SerializeGameState(GameState gameState)
    {
        using var stream = new MemoryStream();
        using var writer = new BinaryWriter(stream);
        
        // Write game metadata
        writer.Write(gameState.GameId.ToByteArray());
        writer.Write(gameState.SessionId.ToByteArray());
        writer.Write(gameState.GameNumber);
        writer.Write((int)gameState.Status);
        
        // Write players (fixed-size for performance)
        writer.Write(gameState.Players.Count);
        foreach (var player in gameState.Players)
        {
            WritePlayer(writer, player);
        }
        
        // Write card state
        WriteCardArray(writer, gameState.DrawPile);
        WriteCardArray(writer, gameState.DiscardPile);
        WriteCard(writer, gameState.CurrentCard);
        
        // Write game effects
        writer.Write(gameState.AttackStack);
        writer.Write(gameState.ChosenSuit.HasValue);
        if (gameState.ChosenSuit.HasValue)
            writer.Write((int)gameState.ChosenSuit.Value);
        writer.Write(gameState.SkipNextPlayer);
        
        return stream.ToArray();
    }

    private void WriteCard(BinaryWriter writer, Card card)
    {
        writer.Write((byte)card.Suit);
        writer.Write((byte)card.Rank);
        writer.Write(card.Id);
    }

    private void WriteCardArray(BinaryWriter writer, Card[] cards)
    {
        writer.Write(cards.Length);
        foreach (var card in cards)
        {
            WriteCard(writer, card);
        }
    }

    private void WritePlayer(BinaryWriter writer, GamePlayer player)
    {
        writer.Write(player.Id.ToByteArray());
        writer.Write(player.Username);
        WriteCardArray(writer, player.Hand);
        writer.Write(player.PlayOrder);
        writer.Write(player.IsEliminated);
    }

    private static string GetGameStateKey(Guid gameId) => $"game:{gameId}";
    private static string GetGameStateLockKey(Guid sessionId) => $"game_lock:{sessionId}";
    private static string GetSessionGameKey(Guid sessionId) => $"session_game:{sessionId}";
}
```

### High-Performance Game Engine
```csharp
public interface IGameEngine
{
    GameActionResult ProcessCardPlay(GameState gameState, Guid playerId, Card card, CardSuit? chosenSuit);
    GameActionResult ProcessDrawCard(GameState gameState, Guid playerId);
    GameState CreateNewGame(Guid sessionId, List<SessionPlayer> players, int gameNumber);
}

public class GameEngine : IGameEngine
{
    private static readonly ObjectPool<Card[]> CardArrayPool = 
        ObjectPool.Create(new DefaultPooledObjectPolicy<Card[]>());

    public GameActionResult ProcessCardPlay(GameState gameState, Guid playerId, Card card, CardSuit? chosenSuit)
    {
        // Validate it's player's turn
        if (gameState.CurrentPlayerId != playerId)
        {
            return GameActionResult.Failure("NOT_YOUR_TURN", "It's not your turn");
        }

        // Find player
        var playerIndex = FindPlayerIndex(gameState, playerId);
        if (playerIndex == -1)
        {
            return GameActionResult.Failure("PLAYER_NOT_FOUND", "Player not in game");
        }

        var player = gameState.Players[playerIndex];
        
        // Validate card is in player's hand
        if (!HasCard(player.Hand, card))
        {
            return GameActionResult.Failure("CARD_NOT_IN_HAND", "Card not in your hand");
        }

        // Validate move is legal
        if (!IsValidPlay(gameState.CurrentCard, card, gameState.AttackStack > 0))
        {
            return GameActionResult.Failure("INVALID_PLAY", "Invalid card play");
        }

        // Create new game state (immutable)
        var newGameState = ApplyCardPlay(gameState, playerIndex, card, chosenSuit);
        
        return GameActionResult.Success(newGameState);
    }

    private GameState ApplyCardPlay(GameState gameState, int playerIndex, Card card, CardSuit? chosenSuit)
    {
        var players = gameState.Players.ToArray(); // Copy for modification
        var player = players[playerIndex];
        
        // Remove card from player's hand (in-place for performance)
        var newHand = RemoveCardFromHand(player.Hand, card);
        players[playerIndex] = player with { Hand = newHand };
        
        // Add card to discard pile
        var newDiscardPile = AddToDiscardPile(gameState.DiscardPile, card);
        
        // Calculate next player and effects
        var (nextPlayerId, newAttackStack, skipNext) = CalculateCardEffects(
            gameState, card, chosenSuit);
        
        // Check for elimination (hand empty)
        var isEliminated = newHand.All(c => c.IsEmpty);
        if (isEliminated)
        {
            players[playerIndex] = players[playerIndex] with 
            { 
                IsEliminated = true, 
                EliminatedAt = DateTime.UtcNow 
            };
        }

        return gameState with
        {
            Players = players.ToList(),
            CurrentCard = card,
            DiscardPile = newDiscardPile,
            CurrentPlayerId = nextPlayerId,
            AttackStack = newAttackStack,
            ChosenSuit = card.Rank == CardRank.Jack ? chosenSuit : null,
            SkipNextPlayer = skipNext,
            LastUpdated = DateTime.UtcNow,
            Version = gameState.Version + 1
        };
    }

    // High-performance card operations using Span<T>
    private static Card[] RemoveCardFromHand(ReadOnlySpan<Card> hand, Card cardToRemove)
    {
        var newHand = new Card[hand.Length];
        var writeIndex = 0;
        var removed = false;
        
        for (int i = 0; i < hand.Length; i++)
        {
            if (!removed && hand[i].Equals(cardToRemove))
            {
                newHand[writeIndex] = Card.Empty; // Mark as empty slot
                removed = true;
            }
            else
            {
                newHand[writeIndex] = hand[i];
            }
            writeIndex++;
        }
        
        return newHand;
    }

    private static bool HasCard(ReadOnlySpan<Card> hand, Card card)
    {
        foreach (var handCard in hand)
        {
            if (handCard.Equals(card) && !handCard.IsEmpty)
                return true;
        }
        return false;
    }

    private static bool IsValidPlay(Card currentCard, Card playedCard, bool isUnderAttack)
    {
        // Attack chain validation
        if (isUnderAttack)
        {
            return playedCard.Rank is CardRank.Seven or CardRank.Joker;
        }

        // Transparent 2 can be played on anything (except during attack)
        if (playedCard.Rank == CardRank.Two)
            return true;

        // Jack can be played on anything (except during attack)
        if (playedCard.Rank == CardRank.Jack)
            return true;

        // Joker color matching or joker-on-joker
        if (playedCard.Rank == CardRank.Joker)
        {
            return currentCard.Rank == CardRank.Joker || 
                   playedCard.Color == currentCard.Color;
        }

        // Standard matching: same suit or rank
        return playedCard.Suit == currentCard.Suit || 
               playedCard.Rank == currentCard.Rank;
    }

    private (Guid nextPlayerId, int attackStack, bool skipNext) CalculateCardEffects(
        GameState gameState, Card playedCard, CardSuit? chosenSuit)
    {
        var currentPlayerIndex = FindPlayerIndex(gameState, gameState.CurrentPlayerId);
        var nextPlayerIndex = GetNextPlayerIndex(gameState, currentPlayerIndex);
        var nextPlayerId = gameState.Players[nextPlayerIndex].Id;

        return playedCard.Rank switch
        {
            CardRank.Ace => (GetPlayerAfterNext(gameState, currentPlayerIndex), 0, true),
            CardRank.Seven => (nextPlayerId, gameState.AttackStack + 2, false),
            CardRank.Joker => (nextPlayerId, gameState.AttackStack + 4, false),
            _ => (nextPlayerId, 0, false) // Regular card
        };
    }

    private static int FindPlayerIndex(GameState gameState, Guid playerId)
    {
        for (int i = 0; i < gameState.Players.Count; i++)
        {
            if (gameState.Players[i].Id == playerId)
                return i;
        }
        return -1;
    }

    private static int GetNextPlayerIndex(GameState gameState, int currentIndex)
    {
        var activePlayers = gameState.Players.Where(p => !p.IsEliminated).ToArray();
        if (activePlayers.Length <= 1) return currentIndex;

        var direction = gameState.TurnDirection;
        var nextIndex = (currentIndex + direction + activePlayers.Length) % activePlayers.Length;
        
        return Array.FindIndex(gameState.Players.ToArray(), p => p.Id == activePlayers[nextIndex].Id);
    }
}

public record GameActionResult
{
    public bool IsSuccess { get; init; }
    public string? Error { get; init; }
    public string? Message { get; init; }
    public GameState? NewGameState { get; init; }
    public Card? DrawnCard { get; init; }

    public static GameActionResult Success(GameState gameState, Card? drawnCard = null) =>
        new() { IsSuccess = true, NewGameState = gameState, DrawnCard = drawnCard };

    public static GameActionResult Failure(string error, string message) =>
        new() { IsSuccess = false, Error = error, Message = message };
}
```

### Memory Pool and Object Reuse
```csharp
public class GameStatePool
{
    private readonly ConcurrentQueue<Card[]> _cardArrays = new();
    private readonly ConcurrentQueue<GamePlayer[]> _playerArrays = new();
    
    public Card[] GetCardArray(int size)
    {
        if (_cardArrays.TryDequeue(out var array) && array.Length >= size)
        {
            Array.Clear(array, 0, array.Length);
            return array;
        }
        
        return new Card[size];
    }
    
    public void ReturnCardArray(Card[] array)
    {
        if (array.Length <= 64) // Don't pool very large arrays
        {
            _cardArrays.Enqueue(array);
        }
    }
}

// Usage in DI
services.AddSingleton<GameStatePool>();
```

### Performance Monitoring
```csharp
public static class GameMetrics
{
    private static readonly Counter<long> GameActionsProcessed = 
        CheckGameMeterProvider.Meter.CreateCounter<long>("game_actions_processed_total");
    
    private static readonly Histogram<double> GameActionDuration = 
        CheckGameMeterProvider.Meter.CreateHistogram<double>("game_action_duration_seconds");
    
    private static readonly Gauge<int> ActiveGames = 
        CheckGameMeterProvider.Meter.CreateGauge<int>("active_games_total");

    public static void RecordActionProcessed(string actionType)
    {
        GameActionsProcessed.Add(1, new KeyValuePair<string, object?>("action_type", actionType));
    }
    
    public static void RecordActionDuration(string actionType, double duration)
    {
        GameActionDuration.Record(duration, new KeyValuePair<string, object?>("action_type", actionType));
    }
}
```

This in-memory approach eliminates database bottlenecks during gameplay while maintaining data consistency through Redis and providing extremely fast response times for all player actions.