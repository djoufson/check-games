using CheckGame.Engine.Models;
using FluentAssertions;

namespace CheckGame.Engine.Tests.Unit.Card;

public class StringFormatTests
{
    [Fact]
    public void ToString_ShouldReturnCorrectFormat_ForRegularCard()
    {
        // Arrange
        var card = Models.Card.NewCard(Suit.Hearts, Rank.King);

        // Act
        var result = card.ToString();

        // Assert
        result.Should().Be("King of Hearts");
    }

    [Fact]
    public void ToString_ShouldReturnCorrectFormat_ForRedJoker()
    {
        // Arrange
        var joker = Models.Card.NewRedJoker();

        // Act
        var result = joker.ToString();

        // Assert
        result.Should().Be("Red Joker");
    }

    [Fact]
    public void ToString_ShouldReturnCorrectFormat_ForBlackJoker()
    {
        // Arrange
        var joker = Models.Card.NewBlackJoker();

        // Act
        var result = joker.ToString();

        // Assert
        result.Should().Be("Black Joker");
    }

    [Theory]
    [InlineData(Suit.Spades, Rank.Ace, "Ace of Spades")]
    [InlineData(Suit.Hearts, Rank.Two, "Two of Hearts")]
    [InlineData(Suit.Diamonds, Rank.Jack, "Jack of Diamonds")]
    [InlineData(Suit.Clubs, Rank.Queen, "Queen of Clubs")]
    public void ToString_ShouldReturnCorrectFormat_ForVariousCards(Suit suit, Rank rank, string expected)
    {
        // Arrange
        var card = Models.Card.NewCard(suit, rank);

        // Act
        var result = card.ToString();

        // Assert
        result.Should().Be(expected);
    }

    [Fact]
    public void Display_ShouldReturnSameAsToString_ForRegularCard()
    {
        // Arrange
        var card = Models.Card.NewCard(Suit.Hearts, Rank.King);

        // Act & Assert
        card.Display.Should().Be(card.ToString());
    }

    [Fact]
    public void Display_ShouldReturnSameAsToString_ForJoker()
    {
        // Arrange
        var joker = Models.Card.NewRedJoker();

        // Act & Assert
        joker.Display.Should().Be(joker.ToString());
    }
}