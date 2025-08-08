using System.Text.Json.Serialization;

namespace CheckGame.Engine.Models;

/// <summary>
/// Represents a player in the game
/// </summary>
/// <remarks>
/// Initializes a new instance of the Player class
/// </remarks>
/// <param name="id">The player's unique identifier</param>
public class Player(string id)
{
    private readonly List<Card> _hand = [];

    /// <summary>
    /// Gets the player's ID
    /// </summary>
    public string Id { get; } = id ?? throw new ArgumentNullException(nameof(id));

    /// <summary>
    /// Gets the player's hand (read-only)
    /// </summary
    public IReadOnlyList<Card> Hand => _hand.AsReadOnly();

    /// <summary>
    /// Creates a new player with the given ID and an empty hand
    /// </summary>
    /// <param name="id">The player's unique identifier</param>
    /// <returns>A new player instance</returns>
    public static Player New(string id) => new(id);

    /// <summary>
    /// Adds a card to the player's hand
    /// </summary>
    /// <param name="card">The card to add</param>
    public void AddToHand(Card card)
    {
        ArgumentNullException.ThrowIfNull(card);
        _hand.Add(card);
    }

    /// <summary>
    /// Adds multiple cards to the player's hand
    /// </summary>
    /// <param name="cards">The cards to add</param>
    public void AddCardsToHand(IEnumerable<Card> cards)
    {
        ArgumentNullException.ThrowIfNull(cards);
        _hand.AddRange(cards);
    }

    /// <summary>
    /// Removes a card from the player's hand
    /// </summary>
    /// <param name="card">The card to remove</param>
    /// <returns>The removed card and success flag</returns>
    public (Card? card, bool success) RemoveFromHand(Card card)
    {
        ArgumentNullException.ThrowIfNull(card);

        for (int i = 0; i < _hand.Count; i++)
        {
            var handCard = _hand[i];
            if (handCard.Equals(card))
            {
                _hand.RemoveAt(i);
                return (card, true);
            }
        }

        return (default, false);
    }

    /// <summary>
    /// Returns true if the player has the specified card in their hand
    /// </summary>
    /// <param name="card">The card to check for</param>
    /// <returns>True if the player has the card</returns>
    public bool HasCard(Card card)
    {
        ArgumentNullException.ThrowIfNull(card);
        return _hand.Any(handCard => handCard.Equals(card));
    }

    /// <summary>
    /// Returns true if the player has a card that matches the specified card
    /// according to the game rules
    /// </summary>
    /// <param name="card">The card to match against</param>
    /// <param name="includeWildCards">Whether to include wild card matching</param>
    /// <returns>True if the player has a matching card</returns>
    public bool HasMatchingCard(Card card, bool includeWildCards)
    {
        ArgumentNullException.ThrowIfNull(card);

        foreach (var handCard in _hand)
        {
            // Transparent card (2) can be played on any card
            if (handCard.IsTransparent())
            {
                return true;
            }

            // Wild cards can be played on other wild cards
            if (includeWildCards && handCard.IsWildCard() && card.IsWildCard())
            {
                return true;
            }

            // Regular matching: same suit or same rank
            if (handCard.Suit == card.Suit || handCard.Rank == card.Rank)
            {
                return true;
            }

            // Joker color matching
            if (handCard.IsJoker() && card.Color == handCard.Color)
            {
                return true;
            }
        }

        return false;
    }

    /// <summary>
    /// Returns a list of cards that the player can play on the specified card
    /// </summary>
    /// <param name="card">The card to play on</param>
    /// <param name="inAttackChain">Whether the game is in an attack chain</param>
    /// <returns>List of playable cards</returns>
    public List<Card> GetPlayableCards(Card card, bool inAttackChain)
    {
        ArgumentNullException.ThrowIfNull(card);

        var playable = new List<Card>();

        foreach (var handCard in _hand)
        {
            if (CanPlayCardOn(handCard, card, inAttackChain))
            {
                playable.Add(handCard);
            }
        }

        return playable;
    }

    /// <summary>
    /// Checks if a card can be played on another card according to the rules
    /// </summary>
    /// <param name="playedCard">The card being played</param>
    /// <param name="topCard">The card on top of the discard pile</param>
    /// <param name="inAttackChain">Whether the game is in an attack chain</param>
    /// <returns>True if the card can be played</returns>
    public static bool CanPlayCardOn(Card playedCard, Card topCard, bool inAttackChain)
    {
        ArgumentNullException.ThrowIfNull(playedCard);
        ArgumentNullException.ThrowIfNull(topCard);

        // In an attack chain, only wild cards can be played on wild cards
        if (inAttackChain)
        {
            if (topCard.IsWildCard())
            {
                return playedCard.IsWildCard();
            }
            return false;
        }

        // Transparent card (2) and Suit changer (Jack) can be played on any card except during attack chain
        if (playedCard.IsTransparent() || playedCard.IsSuitChanger())
        {
            return true;
        }

        // Wild cards can be played on other wild cards (7 or Joker)
        if (playedCard.IsWildCard() && topCard.IsWildCard())
        {
            return true;
        }

        // Regular matching: same suit or same rank
        if (playedCard.Suit == topCard.Suit || playedCard.Rank == topCard.Rank)
        {
            return true;
        }

        // Joker color matching
        if (playedCard.IsJoker() && topCard.Color == playedCard.Color)
        {
            return true;
        }

        return false;
    }

    /// <summary>
    /// Gets the number of cards in the player's hand
    /// </summary>
    /// <returns>The hand size</returns>
    public int HandSize() => _hand.Count;

    /// <summary>
    /// Returns true if the player has no cards left
    /// </summary>
    /// <returns>True if the hand is empty</returns>
    public bool HasEmptyHand() => _hand.Count == 0;

    /// <summary>
    /// Creates a copy of the player
    /// </summary>
    /// <returns>A new player instance with the same ID and hand</returns>
    public Player Clone()
    {
        var clone = new Player(Id);
        clone._hand.AddRange(_hand);
        return clone;
    }

    /// <summary>
    /// Clears all cards from the player's hand
    /// </summary>
    public void ClearHand()
    {
        _hand.Clear();
    }
}