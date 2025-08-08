using CheckGame.Engine.Models;
using FluentAssertions;

namespace CheckGame.Engine.Tests.Unit.Deck;

public class DeckShuffleTests
{
    [Fact]
    public void Shuffle_ShouldNotChangeCardCount()
    {
        // Arrange
        var deck = Models.Deck.NewStandardDeck();
        var originalCount = deck.Count();

        // Act
        deck.Shuffle(new Random(42));

        // Assert
        deck.Count().Should().Be(originalCount);
    }

    [Fact]
    public void Shuffle_ShouldNotChangeCardContent()
    {
        // Arrange
        var deck = Models.Deck.NewStandardDeck();
        var originalCards = deck.Cards.ToList();

        // Act
        deck.Shuffle(new Random(42));

        // Assert
        deck.Cards.Should().Contain(originalCards);
        deck.Cards.Should().HaveCount(originalCards.Count);
    }

    [Fact]
    public void Shuffle_ShouldChangeOrder_WithDifferentSeeds()
    {
        // Arrange
        var deck1 = Models.Deck.NewStandardDeck();
        var deck2 = Models.Deck.NewStandardDeck();

        // Act
        deck1.Shuffle(new Random(42));
        deck2.Shuffle(new Random(123));

        // Assert
        deck1.Cards.Should().NotEqual(deck2.Cards, "Different seeds should produce different orders");
    }

    [Fact]
    public void Shuffle_ShouldProduceSameOrder_WithSameSeed()
    {
        // Arrange
        var deck1 = Models.Deck.NewStandardDeck();
        var deck2 = Models.Deck.NewStandardDeck();

        // Act
        deck1.Shuffle(new Random(42));
        deck2.Shuffle(new Random(42));

        // Assert
        deck1.Cards.Should().Equal(deck2.Cards, "Same seed should produce same order");
    }

    [Fact]
    public void Shuffle_ShouldThrowException_WhenRandomIsNull()
    {
        // Arrange
        var deck = Models.Deck.NewStandardDeck();

        // Act
        var act = () => deck.Shuffle(null!);

        // Assert
        act.Should().Throw<ArgumentNullException>()
           .WithParameterName("random");
    }

    [Fact]
    public void Shuffle_ShouldHandleEmptyDeck()
    {
        // Arrange
        var deck = new Models.Deck();

        // Act & Assert
        var act = () => deck.Shuffle(new Random());
        act.Should().NotThrow();
        deck.IsEmpty().Should().BeTrue();
    }

    [Fact]
    public void Shuffle_ShouldHandleSingleCard()
    {
        // Arrange
        var card = Models.Card.NewCard(Suit.Hearts, Rank.Ace);
        var deck = new Models.Deck(new[] { card });

        // Act
        deck.Shuffle(new Random());

        // Assert
        deck.Count().Should().Be(1);
        deck.Cards[0].Should().Be(card);
    }
}