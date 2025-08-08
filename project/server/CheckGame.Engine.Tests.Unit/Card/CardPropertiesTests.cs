using CheckGame.Engine.Models;
using FluentAssertions;

namespace CheckGame.Engine.Tests.Unit.Card;

public class CardPropertiesTests
{
    [Fact]
    public void IsWildCard_ShouldReturnTrue_WhenCardIsSeven()
    {
        // Arrange
        var card = Models.Card.NewCard(Suit.Hearts, Rank.Seven);

        // Act & Assert
        card.IsWildCard().Should().BeTrue();
    }

    [Fact]
    public void IsWildCard_ShouldReturnTrue_WhenCardIsJoker()
    {
        // Arrange
        var card = Models.Card.NewRedJoker();

        // Act & Assert
        card.IsWildCard().Should().BeTrue();
    }

    [Fact]
    public void IsWildCard_ShouldReturnFalse_WhenCardIsRegular()
    {
        // Arrange
        var card = Models.Card.NewCard(Suit.Hearts, Rank.King);

        // Act & Assert
        card.IsWildCard().Should().BeFalse();
    }

    [Fact]
    public void IsTransparent_ShouldReturnTrue_WhenCardIsTwo()
    {
        // Arrange
        var card = Models.Card.NewCard(Suit.Spades, Rank.Two);

        // Act & Assert
        card.IsTransparent().Should().BeTrue();
    }

    [Fact]
    public void IsTransparent_ShouldReturnFalse_WhenCardIsNotTwo()
    {
        // Arrange
        var card = Models.Card.NewCard(Suit.Spades, Rank.Three);

        // Act & Assert
        card.IsTransparent().Should().BeFalse();
    }

    [Fact]
    public void IsSkip_ShouldReturnTrue_WhenCardIsAce()
    {
        // Arrange
        var card = Models.Card.NewCard(Suit.Hearts, Rank.Ace);

        // Act & Assert
        card.IsSkip().Should().BeTrue();
    }

    [Fact]
    public void IsSkip_ShouldReturnFalse_WhenCardIsNotAce()
    {
        // Arrange
        var card = Models.Card.NewCard(Suit.Hearts, Rank.King);

        // Act & Assert
        card.IsSkip().Should().BeFalse();
    }

    [Fact]
    public void IsSuitChanger_ShouldReturnTrue_WhenCardIsJack()
    {
        // Arrange
        var card = Models.Card.NewCard(Suit.Diamonds, Rank.Jack);

        // Act & Assert
        card.IsSuitChanger().Should().BeTrue();
    }

    [Fact]
    public void IsSuitChanger_ShouldReturnFalse_WhenCardIsNotJack()
    {
        // Arrange
        var card = Models.Card.NewCard(Suit.Diamonds, Rank.Queen);

        // Act & Assert
        card.IsSuitChanger().Should().BeFalse();
    }

    [Fact]
    public void IsJoker_ShouldReturnTrue_WhenCardIsJoker()
    {
        // Arrange
        var card = Models.Card.NewBlackJoker();

        // Act & Assert
        card.IsJoker().Should().BeTrue();
    }

    [Fact]
    public void IsJoker_ShouldReturnFalse_WhenCardIsNotJoker()
    {
        // Arrange
        var card = Models.Card.NewCard(Suit.Clubs, Rank.Ace);

        // Act & Assert
        card.IsJoker().Should().BeFalse();
    }

    [Theory]
    [InlineData(Rank.Seven, 2)]
    [InlineData(Rank.Ace, 0)]
    [InlineData(Rank.King, 0)]
    public void GetDrawPenalty_ShouldReturnCorrectValue_ForRegularCards(Rank rank, int expectedPenalty)
    {
        // Arrange
        var card = Models.Card.NewCard(Suit.Hearts, rank);

        // Act & Assert
        card.GetDrawPenalty().Should().Be(expectedPenalty);
    }

    [Fact]
    public void GetDrawPenalty_ShouldReturnFour_ForJoker()
    {
        // Arrange
        var card = Models.Card.NewRedJoker();

        // Act & Assert
        card.GetDrawPenalty().Should().Be(4);
    }
}