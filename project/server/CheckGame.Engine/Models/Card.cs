using System.Text.Json.Serialization;

namespace CheckGame.Engine.Models;

/// <summary>
/// Represents the suit of a playing card
/// </summary>
public enum Suit
{
    Spades,
    Hearts,
    Diamonds,
    Clubs,
    Joker
}

/// <summary>
/// Represents the rank of a playing card
/// </summary>
public enum Rank
{
    Ace = 1,
    Two,
    Three,
    Four,
    Five,
    Six,
    Seven,
    Eight,
    Nine,
    Ten,
    Jack,
    Queen,
    King
}

/// <summary>
/// Represents the color of a playing card
/// </summary>
public enum Color
{
    Red,
    Black
}

/// <summary>
/// Represents a playing card with a suit, rank, and color
/// </summary>
public record Card
{
    /// <summary>
    /// Gets the suit of the card
    /// </summary>
    public required Suit Suit { get; init; }

    /// <summary>
    /// Gets the rank of the card
    /// </summary>
    public required Rank? Rank { get; init; }

    /// <summary>
    /// Gets the color of the card
    /// </summary>

    public required Color Color { get; init; }

    /// <summary>
    /// Gets the display string for the card (used for JSON serialization)
    /// </summary>
    public string Display => ToString();

    /// <summary>
    /// Creates a new card with the given suit and rank, automatically assigning the color
    /// </summary>
    /// <param name="suit">The suit of the card</param>
    /// <param name="rank">The rank of the card</param>
    /// <returns>A new card instance</returns>
    public static Card NewCard(Suit suit, Rank rank)
    {
        var color = suit switch
        {
            Suit.Hearts or Suit.Diamonds => Color.Red,
            Suit.Spades or Suit.Clubs => Color.Black,
            Suit.Joker => throw new ArgumentException("Use NewRedJoker() or NewBlackJoker() for joker cards", nameof(suit)),
            _ => throw new ArgumentOutOfRangeException(nameof(suit), suit, "Invalid suit")
        };

        return new Card
        {
            Suit = suit,
            Rank = rank,
            Color = color
        };
    }

    /// <summary>
    /// Creates a new red joker card
    /// </summary>
    /// <returns>A new red joker card</returns>
    public static Card NewRedJoker()
    {
        return new Card
        {
            Suit = Suit.Joker,
            Rank = null,
            Color = Color.Red
        };
    }

    /// <summary>
    /// Creates a new black joker card
    /// </summary>
    /// <returns>A new black joker card</returns>
    public static Card NewBlackJoker()
    {
        return new Card
        {
            Suit = Suit.Joker,
            Rank = null,
            Color = Color.Black
        };
    }

    /// <summary>
    /// Returns true if the card is a joker
    /// </summary>
    /// <returns>True if the card is a joker</returns>
    public bool IsJoker() => Suit == Suit.Joker;

    /// <summary>
    /// Returns true if the card is a wild card (7 or Joker)
    /// </summary>
    /// <returns>True if the card is a wild card</returns>
    public bool IsWildCard() => Rank == Models.Rank.Seven || IsJoker();

    /// <summary>
    /// Returns true if the card is transparent (rank 2)
    /// </summary>
    /// <returns>True if the card is transparent</returns>
    public bool IsTransparent() => Rank == Models.Rank.Two;

    /// <summary>
    /// Returns true if the card skips the next player (Ace)
    /// </summary>
    /// <returns>True if the card skips the next player</returns>
    public bool IsSkip() => Rank == Models.Rank.Ace;

    /// <summary>
    /// Returns true if the card can change the suit (Jack)
    /// </summary>
    /// <returns>True if the card can change the suit</returns>
    public bool IsSuitChanger() => Rank == Models.Rank.Jack;

    /// <summary>
    /// Returns the number of cards to draw as penalty for this card
    /// </summary>
    /// <returns>The draw penalty amount</returns>
    public int GetDrawPenalty()
    {
        return Rank switch
        {
            Models.Rank.Seven => 2,
            _ when IsJoker() => 4,
            _ => 0
        };
    }

    /// <summary>
    /// Returns a string representation of the card
    /// </summary>
    /// <returns>String representation of the card</returns>
    public override string ToString()
    {
        if (IsJoker())
        {
            return $"{Color} Joker";
        }
        return $"{Rank} of {Suit}";
    }

    /// <summary>
    /// Determines if two cards are equal based on suit, rank, and color
    /// </summary>
    /// <param name="other">The other card to compare</param>
    /// <returns>True if the cards are equal</returns>
    public virtual bool Equals(Card? other)
    {
        return other is not null &&
               Suit == other.Suit &&
               Rank == other.Rank &&
               Color == other.Color;
    }

    /// <summary>
    /// Gets the hash code for the card
    /// </summary>
    /// <returns>Hash code</returns>
    public override int GetHashCode() => HashCode.Combine(Suit, Rank, Color);
}