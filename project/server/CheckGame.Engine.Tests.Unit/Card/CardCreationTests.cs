using CheckGame.Engine.Models;
using FluentAssertions;

namespace CheckGame.Engine.Tests.Unit.Card;

public class CardCreationTests
{
    [Fact]
    public void NewCard_ShouldSetSuitCorrectly_WhenCreatingCard()
    {
        // Arrange & Act
        var card = Models.Card.NewCard(Suit.Spades, Rank.Ace);

        // Assert
        card.Suit.Should().Be(Suit.Spades);
    }

    [Fact]
    public void NewCard_ShouldSetRankCorrectly_WhenCreatingCard()
    {
        // Arrange & Act
        var card = Models.Card.NewCard(Suit.Spades, Rank.Ace);

        // Assert
        card.Rank.Should().Be(Rank.Ace);
    }

    [Fact]
    public void NewCard_ShouldSetBlackColor_WhenSuitIsSpades()
    {
        // Arrange & Act
        var card = Models.Card.NewCard(Suit.Spades, Rank.Ace);

        // Assert
        card.Color.Should().Be(Color.Black);
    }

    [Fact]
    public void NewCard_ShouldSetBlackColor_WhenSuitIsClubs()
    {
        // Arrange & Act
        var card = Models.Card.NewCard(Suit.Clubs, Rank.King);

        // Assert
        card.Color.Should().Be(Color.Black);
    }

    [Fact]
    public void NewCard_ShouldSetRedColor_WhenSuitIsHearts()
    {
        // Arrange & Act
        var card = Models.Card.NewCard(Suit.Hearts, Rank.King);

        // Assert
        card.Color.Should().Be(Color.Red);
    }

    [Fact]
    public void NewCard_ShouldSetRedColor_WhenSuitIsDiamonds()
    {
        // Arrange & Act
        var card = Models.Card.NewCard(Suit.Diamonds, Rank.Queen);

        // Assert
        card.Color.Should().Be(Color.Red);
    }

    [Fact]
    public void NewCard_ShouldThrowException_WhenSuitIsJoker()
    {
        // Arrange & Act & Assert
        var act = () => Models.Card.NewCard(Suit.Joker, Rank.Ace);

        act.Should().Throw<ArgumentException>()
           .WithParameterName("suit")
           .WithMessage("Use NewRedJoker() or NewBlackJoker() for joker cards*");
    }
}