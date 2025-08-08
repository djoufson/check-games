using CheckGame.Engine.Models;
using FluentAssertions;

namespace CheckGame.Engine.Tests.Unit.Deck;

public class DeckDrawTests
{
    [Fact]
    public void Draw_ShouldReturnTopCard_WhenDeckHasCards()
    {
        // Arrange
        var topCard = Models.Card.NewCard(Suit.Hearts, Rank.Ace);
        var bottomCard = Models.Card.NewCard(Suit.Spades, Rank.King);
        var deck = new Models.Deck(new[] { topCard, bottomCard });

        // Act
        var (drawnCard, success) = deck.Draw();

        // Assert
        success.Should().BeTrue();
        drawnCard.Should().Be(topCard);
        deck.Count().Should().Be(1);
        deck.Cards.Should().Contain(bottomCard);
        deck.Cards.Should().NotContain(topCard);
    }

    [Fact]
    public void Draw_ShouldReturnFailure_WhenDeckIsEmpty()
    {
        // Arrange
        var deck = new Models.Deck();

        // Act
        var (drawnCard, success) = deck.Draw();

        // Assert
        success.Should().BeFalse();
        drawnCard.Should().Be(default);
    }

    [Fact]
    public void DrawN_ShouldReturnRequestedCards_WhenDeckHasEnoughCards()
    {
        // Arrange
        var cards = new[]
        {
            Models.Card.NewCard(Suit.Hearts, Rank.Ace),
            Models.Card.NewCard(Suit.Spades, Rank.King),
            Models.Card.NewCard(Suit.Diamonds, Rank.Queen),
            Models.Card.NewCard(Suit.Clubs, Rank.Jack)
        };
        var deck = new Models.Deck(cards);

        // Act
        var (drawnCards, success) = deck.DrawN(2);

        // Assert
        success.Should().BeTrue();
        drawnCards.Should().HaveCount(2);
        drawnCards[0].Should().Be(cards[0]);
        drawnCards[1].Should().Be(cards[1]);
        deck.Count().Should().Be(2);
    }

    [Fact]
    public void DrawN_ShouldReturnFailure_WhenDeckDoesNotHaveEnoughCards()
    {
        // Arrange
        var cards = new[]
        {
            Models.Card.NewCard(Suit.Hearts, Rank.Ace),
            Models.Card.NewCard(Suit.Spades, Rank.King)
        };
        var deck = new Models.Deck(cards);

        // Act
        var (drawnCards, success) = deck.DrawN(3);

        // Assert
        success.Should().BeFalse();
        drawnCards.Should().BeEmpty();
        deck.Count().Should().Be(2); // Deck should be unchanged
    }

    [Fact]
    public void DrawN_ShouldReturnEmptyArray_WhenCountIsZero()
    {
        // Arrange
        var deck = Models.Deck.NewStandardDeck();

        // Act
        var (drawnCards, success) = deck.DrawN(0);

        // Assert
        success.Should().BeTrue();
        drawnCards.Should().BeEmpty();
        deck.Count().Should().Be(54); // Deck should be unchanged
    }

    [Fact]
    public void DrawN_ShouldThrowException_WhenCountIsNegative()
    {
        // Arrange
        var deck = Models.Deck.NewStandardDeck();

        // Act
        var act = () => deck.DrawN(-1);

        // Assert
        act.Should().Throw<ArgumentException>()
           .WithParameterName("count")
           .WithMessage("Count must be non-negative*");
    }
}