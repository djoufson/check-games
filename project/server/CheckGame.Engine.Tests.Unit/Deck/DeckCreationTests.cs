using CheckGame.Engine.Models;
using FluentAssertions;

namespace CheckGame.Engine.Tests.Unit.Deck;

public class DeckCreationTests
{
    [Fact]
    public void NewStandardDeck_ShouldCreate54Cards()
    {
        // Arrange & Act
        var deck = Models.Deck.NewStandardDeck();

        // Assert
        deck.Count().Should().Be(54);
    }

    [Fact]
    public void NewStandardDeck_ShouldContainAllStandardCards()
    {
        // Arrange
        var deck = Models.Deck.NewStandardDeck();

        // Act
        var suits = new[] { Suit.Spades, Suit.Hearts, Suit.Diamonds, Suit.Clubs };
        var ranks = Enum.GetValues<Rank>();

        // Assert
        foreach (var suit in suits)
        {
            foreach (var rank in ranks)
            {
                var expectedCard = Models.Card.NewCard(suit, rank);
                deck.Cards.Should().Contain(card => card.Equals(expectedCard));
            }
        }
    }

    [Fact]
    public void NewStandardDeck_ShouldContainTwoJokers()
    {
        // Arrange & Act
        var deck = Models.Deck.NewStandardDeck();

        // Assert
        var jokers = deck.Cards.Where(c => c.IsJoker()).ToList();
        jokers.Should().HaveCount(2);
        jokers.Should().Contain(card => card.Color == Color.Red);
        jokers.Should().Contain(card => card.Color == Color.Black);
    }

    [Fact]
    public void NewDeck_ShouldCreateEmptyDeck_WhenNoCardsProvided()
    {
        // Arrange & Act
        var deck = new Models.Deck();

        // Assert
        deck.Count().Should().Be(0);
        deck.IsEmpty().Should().BeTrue();
    }

    [Fact]
    public void NewDeck_ShouldCreateDeckWithProvidedCards()
    {
        // Arrange
        var cards = new[]
        {
            Models.Card.NewCard(Suit.Hearts, Rank.Ace),
            Models.Card.NewCard(Suit.Spades, Rank.King)
        };

        // Act
        var deck = new Models.Deck(cards);

        // Assert
        deck.Count().Should().Be(2);
        deck.Cards.Should().Equal(cards);
    }
}