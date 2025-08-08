using CheckGame.Engine.Models;

namespace CheckGame.Engine.Models;

/// <summary>
/// Represents a deck of cards
/// </summary>
public class Deck
{
    private readonly List<Card> _cards;

    /// <summary>
    /// Gets the cards in the deck
    /// </summary>
    public IReadOnlyList<Card> Cards => _cards.AsReadOnly();

    /// <summary>
    /// Initializes a new instance of the Deck class
    /// </summary>
    /// <param name="cards">Optional list of cards to initialize the deck with</param>
    public Deck(IEnumerable<Card>? cards = null)
    {
        _cards = cards?.ToList() ?? [];
    }

    /// <summary>
    /// Creates a new standard deck of cards (52 cards + 2 jokers)
    /// </summary>
    /// <returns>A new standard deck</returns>
    public static Deck NewStandardDeck()
    {
        var cards = new List<Card>(54);

        // Add all standard cards
        var suits = new[] { Suit.Spades, Suit.Hearts, Suit.Diamonds, Suit.Clubs };
        var ranks = Enum.GetValues<Rank>();

        foreach (var suit in suits)
        {
            foreach (var rank in ranks)
            {
                cards.Add(Card.NewCard(suit, rank));
            }
        }

        // Add jokers
        cards.Add(Card.NewRedJoker());
        cards.Add(Card.NewBlackJoker());

        return new Deck(cards);
    }

    /// <summary>
    /// Shuffles the deck using the Fisher-Yates algorithm
    /// </summary>
    /// <param name="random">Random number generator to use for shuffling</param>
    public void Shuffle(Random random)
    {
        ArgumentNullException.ThrowIfNull(random);

        // Fisher-Yates shuffle
        for (int i = _cards.Count - 1; i > 0; i--)
        {
            int j = random.Next(i + 1);
            (_cards[i], _cards[j]) = (_cards[j], _cards[i]);
        }
    }

    /// <summary>
    /// Draws the top card from the deck
    /// </summary>
    /// <returns>The drawn card and success flag</returns>
    public (Card? card, bool success) Draw()
    {
        if (_cards.Count == 0)
        {
            return (default, false);
        }

        var card = _cards[0];
        _cards.RemoveAt(0);
        return (card, true);
    }

    /// <summary>
    /// Draws multiple cards from the top of the deck
    /// </summary>
    /// <param name="count">Number of cards to draw</param>
    /// <returns>The drawn cards and success flag</returns>
    public (Card[] cards, bool success) DrawN(int count)
    {
        if (count < 0)
        {
            throw new ArgumentException("Count must be non-negative", nameof(count));
        }

        if (_cards.Count < count)
        {
            return (Array.Empty<Card>(), false);
        }

        var drawnCards = _cards.Take(count).ToArray();
        _cards.RemoveRange(0, count);
        return (drawnCards, true);
    }

    /// <summary>
    /// Adds a card to the bottom of the deck
    /// </summary>
    /// <param name="card">The card to add</param>
    public void AddToBottom(Card card)
    {
        ArgumentNullException.ThrowIfNull(card);
        _cards.Add(card);
    }

    /// <summary>
    /// Adds a card to the top of the deck
    /// </summary>
    /// <param name="card">The card to add</param>
    public void AddToTop(Card card)
    {
        ArgumentNullException.ThrowIfNull(card);
        _cards.Insert(0, card);
    }

    /// <summary>
    /// Adds multiple cards to the bottom of the deck
    /// </summary>
    /// <param name="cards">The cards to add</param>
    public void AddManyToBottom(IEnumerable<Card> cards)
    {
        ArgumentNullException.ThrowIfNull(cards);
        _cards.AddRange(cards);
    }

    /// <summary>
    /// Gets the number of cards in the deck
    /// </summary>
    /// <returns>The number of cards</returns>
    public int Count() => _cards.Count;

    /// <summary>
    /// Returns true if the deck has no cards
    /// </summary>
    /// <returns>True if the deck is empty</returns>
    public bool IsEmpty() => _cards.Count == 0;

    /// <summary>
    /// Creates a copy of the deck
    /// </summary>
    /// <returns>A new deck instance with the same cards</returns>
    public Deck Clone()
    {
        return new Deck(_cards);
    }

    /// <summary>
    /// Clears all cards from the deck
    /// </summary>
    public void Clear()
    {
        _cards.Clear();
    }
}