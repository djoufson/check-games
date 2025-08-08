using System.Text.Json;
using System.Text.Json.Serialization;

namespace CheckGame.Engine.Models;

/// <summary>
/// Represents the direction of play
/// </summary>
public enum Direction
{
    /// <summary>
    /// Clockwise direction (standard)
    /// </summary>
    Clockwise = 0,
    /// <summary>
    /// Counter-clockwise direction (reverse)
    /// </summary>
    CounterClockwise = 1
}

/// <summary>
/// Game options for creating a new game state
/// </summary>
public record GameOptions
{
    /// <summary>
    /// Gets or sets the number of cards dealt to each player at start
    /// </summary>
    public int InitialCards { get; init; } = 7;

    /// <summary>
    /// Gets or sets the seed for random number generation
    /// </summary>
    public int? RandomSeed { get; init; }

    /// <summary>
    /// Gets or sets custom players for testing or restarting a game
    /// </summary>
    public List<Player>? CustomPlayers { get; init; }
}

/// <summary>
/// Represents the current state of a game
/// </summary>
public class GameState
{
    private readonly List<Player> _players;
    private readonly List<string> _activePlayers;
    private readonly List<Card> _discardPile;

    /// <summary>
    /// Gets the players in the game
    /// </summary>
    public IReadOnlyList<Player> Players => _players.AsReadOnly();

    /// <summary>
    /// Gets the IDs of players still active in the game
    /// </summary>
    public IReadOnlyList<string> ActivePlayers => _activePlayers.AsReadOnly();

    /// <summary>
    /// Gets the ID of the current player
    /// </summary>
    public string CurrentPlayerId { get; private set; }

    /// <summary>
    /// Gets the direction of play
    /// </summary>

    public Direction Direction { get; private set; }

    /// <summary>
    /// Gets the draw pile
    /// </summary>
    public Deck DrawPile { get; private set; }

    /// <summary>
    /// Gets the discard pile
    /// </summary>
    public IReadOnlyList<Card> DiscardPile => _discardPile.AsReadOnly();

    /// <summary>
    /// Gets the top card of the discard pile
    /// </summary>
    public Card TopCard { get; private set; }

    /// <summary>
    /// Gets whether the game is in an attack chain
    /// </summary>
    public bool InAttackChain { get; private set; }

    /// <summary>
    /// Gets the accumulated attack amount
    /// </summary>
    public int AttackAmount { get; private set; }

    /// <summary>
    /// Gets the last active suit (for Jack's suit change effect)
    /// </summary>
    public Suit LastActiveSuit { get; private set; }

    /// <summary>
    /// Gets whether the turn is locked until the suit is changed
    /// </summary>
    public bool LockedTurn { get; private set; }

    /// <summary>
    /// Initializes a new instance of the GameState class
    /// </summary>
    public GameState(
        List<Player> players,
        List<string> activePlayerIds,
        string currentPlayerId,
        Direction direction,
        Deck drawPile,
        List<Card> discardPile,
        Card topCard,
        bool inAttackChain = false,
        int attackAmount = 0,
        Suit? lastActiveSuit = null,
        bool lockedTurn = false)
    {
        _players = players ?? throw new ArgumentNullException(nameof(players));
        _activePlayers = activePlayerIds ?? throw new ArgumentNullException(nameof(activePlayerIds));
        CurrentPlayerId = currentPlayerId ?? throw new ArgumentNullException(nameof(currentPlayerId));
        Direction = direction;
        DrawPile = drawPile ?? throw new ArgumentNullException(nameof(drawPile));
        _discardPile = discardPile ?? throw new ArgumentNullException(nameof(discardPile));
        TopCard = topCard ?? throw new ArgumentNullException(nameof(topCard));
        InAttackChain = inAttackChain;
        AttackAmount = attackAmount;
        LastActiveSuit = lastActiveSuit ?? topCard.Suit;
        LockedTurn = lockedTurn;
    }

    /// <summary>
    /// Creates a new game state with the given player IDs and options
    /// </summary>
    /// <param name="playerIds">The player IDs</param>
    /// <param name="options">Game options (optional)</param>
    /// <returns>A new game state</returns>
    public static GameState New(List<string> playerIds, GameOptions? options = null)
    {
        ArgumentNullException.ThrowIfNull(playerIds);

        if (playerIds.Count < 2)
        {
            throw new ArgumentException("At least 2 players are required", nameof(playerIds));
        }

        options ??= new GameOptions();

        // Create random number generator
        var random = options.RandomSeed.HasValue 
            ? new Random(options.RandomSeed.Value) 
            : new Random();

        // Create and shuffle the deck
        var drawPile = Deck.NewStandardDeck();
        drawPile.Shuffle(random);

        // Create players
        var players = new List<Player>();
        foreach (var id in playerIds)
        {
            players.Add(Player.New(id));
        }

        // Deal initial cards
        for (int i = 0; i < options.InitialCards; i++)
        {
            foreach (var player in players)
            {
                var (card, success) = drawPile.Draw();
                if (success)
                {
                    player.AddToHand(card!);
                }
            }
        }

        // Draw the top card for the discard pile
        var (topCard, drawSuccess) = drawPile.Draw();
        if (!drawSuccess)
        {
            throw new InvalidOperationException("Failed to draw initial card for discard pile");
        }

        // Ensure the initial discard card isn't a wild card
        if (topCard!.IsWildCard())
        {
            // Put the wild card back in the deck and shuffle again
            drawPile.AddToBottom(topCard);
            drawPile.Shuffle(random);

            // Draw again
            (topCard, drawSuccess) = drawPile.Draw();
            if (!drawSuccess)
            {
                throw new InvalidOperationException("Failed to draw initial card for discard pile after reshuffle");
            }
        }

        var discardPile = new List<Card> { topCard! };
        var activePlayerIds = playerIds.ToList();

        return new GameState(
            players,
            activePlayerIds,
            activePlayerIds[0],
            Direction.Clockwise,
            drawPile,
            discardPile,
            topCard!,
            lastActiveSuit: topCard!.Suit
        );
    }

    /// <summary>
    /// Creates a deep copy of the game state
    /// </summary>
    /// <returns>A cloned game state</returns>
    public GameState Clone()
    {
        // Clone players
        var clonedPlayers = _players.Select(p => p.Clone()).ToList();

        // Clone active players
        var clonedActivePlayerIds = new List<string>(_activePlayers);

        // Clone draw pile
        var clonedDrawPile = DrawPile.Clone();

        // Clone discard pile
        var clonedDiscardPile = new List<Card>(_discardPile);

        return new GameState(
            clonedPlayers,
            clonedActivePlayerIds,
            CurrentPlayerId,
            Direction,
            clonedDrawPile,
            clonedDiscardPile,
            TopCard,
            InAttackChain,
            AttackAmount,
            LastActiveSuit,
            LockedTurn
        );
    }

    /// <summary>
    /// Gets the current player
    /// </summary>
    /// <returns>The current player or null if not found</returns>
    public Player? CurrentPlayer()
    {
        return _players.FirstOrDefault(p => p.Id == CurrentPlayerId);
    }

    /// <summary>
    /// Gets the index of the next player based on current direction
    /// </summary>
    /// <returns>The next player index</returns>
    public int NextPlayerIndex()
    {
        var numActivePlayers = _activePlayers.Count;
        if (numActivePlayers <= 1)
        {
            return 0; // Only one player left
        }

        var currentIndex = _activePlayers.IndexOf(CurrentPlayerId);
        if (currentIndex == -1)
        {
            return 0;
        }

        return Direction == Direction.Clockwise
            ? (currentIndex + 1) % numActivePlayers
            : (currentIndex - 1 + numActivePlayers) % numActivePlayers;
    }

    /// <summary>
    /// Gets the next player in the play order
    /// </summary>
    /// <returns>The next player or null if only one player left</returns>
    public Player? NextPlayer()
    {
        if (_activePlayers.Count <= 1)
        {
            return null;
        }

        var nextIndex = NextPlayerIndex();
        var nextId = _activePlayers[nextIndex];

        return _players.FirstOrDefault(p => p.Id == nextId);
    }

    /// <summary>
    /// Advances the turn to the next player
    /// </summary>
    public void AdvanceTurn()
    {
        if (_activePlayers.Count <= 1)
        {
            return;
        }

        CurrentPlayerId = _activePlayers[NextPlayerIndex()];
    }

    /// <summary>
    /// Skips the next player's turn (used for Ace)
    /// </summary>
    public void SkipNextPlayer()
    {
        if (_activePlayers.Count <= 2)
        {
            // With 2 players, skipping next is equivalent to playing again
            return;
        }

        // Advance twice
        AdvanceTurn();
        AdvanceTurn();
    }

    /// <summary>
    /// Finds a player by ID
    /// </summary>
    /// <param name="id">The player ID</param>
    /// <returns>The player or null if not found</returns>
    public Player? FindPlayerById(string id)
    {
        return _players.FirstOrDefault(p => p.Id == id);
    }

    /// <summary>
    /// Checks if a player is still active in the game
    /// </summary>
    /// <param name="playerId">The player ID</param>
    /// <returns>True if the player is active</returns>
    public bool IsPlayerActive(string playerId)
    {
        return _activePlayers.Contains(playerId);
    }

    /// <summary>
    /// Removes a player from the active players list
    /// </summary>
    /// <param name="playerId">The player ID to remove</param>
    public void RemovePlayerFromActive(string playerId)
    {
        _activePlayers.Remove(playerId);
    }

    /// <summary>
    /// Plays a card from the player's hand
    /// </summary>
    /// <param name="playerId">The player ID</param>
    /// <param name="card">The card to play</param>
    /// <returns>Error message if unsuccessful, null if successful</returns>
    public string? PlayCard(string playerId, Card card)
    {
        // Check if it's the player's turn
        if (playerId != CurrentPlayerId)
        {
            return "Not your turn";
        }

        // Verify that the turn is not locked
        if (LockedTurn)
        {
            return "Turn is locked";
        }

        // Find the player
        var player = FindPlayerById(playerId);
        if (player == null)
        {
            return "Player not found";
        }

        // Check if the player has the card
        if (!player.HasCard(card))
        {
            return "Card not in hand";
        }

        // Check if the play is valid
        if (!Player.CanPlayCardOn(card, TopCard, InAttackChain))
        {
            return "Invalid play";
        }

        // If in an attack chain, only wild cards can be played on wild cards
        if (InAttackChain && !card.IsWildCard())
        {
            return "Must play a wild card to defend against an attack";
        }

        // Remove the card from the player's hand
        var (removedCard, success) = player.RemoveFromHand(card);
        if (!success)
        {
            return "Failed to remove card from hand";
        }

        // Add the card to the discard pile
        _discardPile.Add(card);
        TopCard = card;

        // Update the last active suit (for Jack's suit change)
        if (!card.IsJoker())
        {
            LastActiveSuit = card.Suit;
        }

        // Handle wild cards
        if (card.IsWildCard())
        {
            if (InAttackChain)
            {
                // Add to the attack amount
                AttackAmount += card.GetDrawPenalty();
            }
            else
            {
                // Start a new attack chain
                InAttackChain = true;
                AttackAmount = card.GetDrawPenalty();
            }
        }

        // Process special card effects
        ProcessCardEffect(card);

        // Check if the player has emptied their hand
        if (player.HasEmptyHand())
        {
            RemovePlayerFromActive(playerId);
        }

        return null; // Success
    }

    /// <summary>
    /// Makes the current player draw a card
    /// </summary>
    /// <param name="playerId">The player ID</param>
    /// <returns>Error message if unsuccessful, null if successful</returns>
    public string? DrawCard(string playerId)
    {
        // Check if it's the player's turn
        if (playerId != CurrentPlayerId)
        {
            return "Not your turn";
        }

        // Find the player
        var player = FindPlayerById(playerId);
        if (player == null)
        {
            return "Player not found";
        }

        // Handle draw pile exhaustion
        if (DrawPile.IsEmpty())
        {
            var reshuffleError = ReshuffleDiscardPile();
            if (reshuffleError != null)
            {
                return reshuffleError;
            }
        }

        // Draw a card for the player
        var (card, success) = DrawPile.Draw();
        if (!success)
        {
            return "Failed to draw card";
        }

        // Add the card to the player's hand
        player.AddToHand(card!);

        // If in an attack chain, the player must draw the attack amount and end the chain
        if (InAttackChain)
        {
            // Draw the remaining attack amount - 1 (we already drew one)
            for (int i = 1; i < AttackAmount; i++)
            {
                // Handle draw pile exhaustion again if needed
                if (DrawPile.IsEmpty())
                {
                    var reshuffleError = ReshuffleDiscardPile();
                    if (reshuffleError != null)
                    {
                        return reshuffleError;
                    }
                }

                var (attackCard, attackSuccess) = DrawPile.Draw();
                if (!attackSuccess)
                {
                    return "Failed to draw attack penalty cards";
                }
                player.AddToHand(attackCard!);
            }

            // End the attack chain
            InAttackChain = false;
            AttackAmount = 0;
        }

        // Advance to the next player's turn
        AdvanceTurn();

        return null; // Success
    }

    /// <summary>
    /// Processes the effect of the played card
    /// </summary>
    /// <param name="card">The card that was played</param>
    public void ProcessCardEffect(Card card)
    {
        if (card.IsSkip())
        {
            // Ace skips the next player
            SkipNextPlayer();
        }
        else if (card.IsWildCard() && InAttackChain)
        {
            // In an attack chain, wild cards DO advance the turn
            // The next player must defend or draw
            AdvanceTurn();
        }
        else if (card.IsSuitChanger())
        {
            // Jack changes the suit
            // So the turn is locked until the suit is changed
            LockTurn();
        }
        else if (!InAttackChain)
        {
            // In normal play, advance to the next player if not in an attack chain
            // and the card isn't a special card that changes turn order
            AdvanceTurn();
        }
    }

    /// <summary>
    /// Locks the turn until the suit is changed
    /// </summary>
    public void LockTurn()
    {
        LockedTurn = true;
    }

    /// <summary>
    /// Unlocks the turn
    /// </summary>
    public void UnlockTurn()
    {
        LockedTurn = false;
    }

    /// <summary>
    /// Reshuffles the discard pile (except top card) into the draw pile
    /// </summary>
    /// <returns>Error message if unsuccessful, null if successful</returns>
    public string? ReshuffleDiscardPile()
    {
        if (_discardPile.Count <= 1)
        {
            return "Not enough cards to reshuffle";
        }

        // Keep the top card
        var topCardToKeep = _discardPile[^1];

        // Add all other discard cards to draw pile
        var cardsToShuffle = _discardPile.Take(_discardPile.Count - 1);
        DrawPile.AddManyToBottom(cardsToShuffle);

        // Reset the discard pile with just the top card
        _discardPile.Clear();
        _discardPile.Add(topCardToKeep);

        // Shuffle the draw pile
        var random = new Random();
        DrawPile.Shuffle(random);

        return null; // Success
    }

    /// <summary>
    /// Changes the active suit (for Jack effect)
    /// </summary>
    /// <param name="playerId">The player ID</param>
    /// <param name="newSuit">The new suit</param>
    /// <returns>Error message if unsuccessful, null if successful</returns>
    public string? ChangeSuit(string playerId, Suit newSuit)
    {
        // Verify it's the player's turn
        if (playerId != CurrentPlayerId)
        {
            return "Not your turn";
        }

        // Verify that the turn is locked
        if (!LockedTurn)
        {
            return "Turn is not locked";
        }

        if (!IsValidSuit(newSuit))
        {
            return "Invalid suit";
        }

        // Verify that the last card played was a Jack
        if (!TopCard.IsSuitChanger())
        {
            return "Suit can only be changed after playing a Jack";
        }

        // Change the suit
        LastActiveSuit = newSuit;
        UnlockTurn();
        AdvanceTurn();

        return null; // Success
    }

    /// <summary>
    /// Checks if a suit is valid for suit changes
    /// </summary>
    /// <param name="suit">The suit to check</param>
    /// <returns>True if valid</returns>
    private static bool IsValidSuit(Suit suit)
    {
        return suit is Suit.Hearts or Suit.Diamonds or Suit.Spades or Suit.Clubs;
    }

    /// <summary>
    /// Checks if the game is over
    /// </summary>
    /// <returns>True if the game is over</returns>
    public bool IsGameOver() => _activePlayers.Count <= 1;

    /// <summary>
    /// Gets the IDs of players who have won (emptied their hands)
    /// </summary>
    /// <returns>List of winner IDs</returns>
    public List<string> GetWinners()
    {
        return _players
            .Where(p => p.HasEmptyHand())
            .Select(p => p.Id)
            .ToList();
    }

    /// <summary>
    /// Gets the ID of the last player left with cards
    /// </summary>
    /// <returns>The loser ID or empty string if game is not over</returns>
    public string GetLoser()
    {
        return _activePlayers.Count == 1 ? _activePlayers[0] : string.Empty;
    }

    /// <summary>
    /// Serializes the game state to JSON
    /// </summary>
    /// <returns>JSON string representation</returns>
    public string ToJson()
    {
        return JsonSerializer.Serialize(this, new JsonSerializerOptions 
        { 
            WriteIndented = true,
            PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower
        });
    }

    /// <summary>
    /// Deserializes the game state from JSON
    /// </summary>
    /// <param name="json">JSON string</param>
    /// <returns>GameState instance</returns>
    public static GameState? FromJson(string json)
    {
        return JsonSerializer.Deserialize<GameState>(json, new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower
        });
    }
}