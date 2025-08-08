using CheckGame.Engine.Models;
using FluentAssertions;

namespace CheckGame.Engine.Tests.Unit.Card;

public class JokerTests
{
    [Fact]
    public void NewRedJoker_ShouldCreateRedJoker()
    {
        // Arrange & Act
        var joker = Models.Card.NewRedJoker();

        // Assert
        joker.Suit.Should().Be(Suit.Joker);
        joker.Color.Should().Be(Color.Red);
        joker.Rank.Should().BeNull();
    }

    [Fact]
    public void NewBlackJoker_ShouldCreateBlackJoker()
    {
        // Arrange & Act
        var joker = Models.Card.NewBlackJoker();

        // Assert
        joker.Suit.Should().Be(Suit.Joker);
        joker.Color.Should().Be(Color.Black);
        joker.Rank.Should().BeNull();
    }

    [Theory]
    [InlineData(Color.Red)]
    [InlineData(Color.Black)]
    public void JokerColorMatching_ShouldWork_WithSameColorCards(Color jokerColor)
    {
        // Arrange
        var joker = jokerColor == Color.Red ? Models.Card.NewRedJoker() : Models.Card.NewBlackJoker();
        var redCard = Models.Card.NewCard(Suit.Hearts, Rank.King);
        var blackCard = Models.Card.NewCard(Suit.Spades, Rank.Queen);
        
        var targetCard = jokerColor == Color.Red ? redCard : blackCard;

        // Act
        var canPlay = Models.Player.CanPlayCardOn(joker, targetCard, inAttackChain: false);

        // Assert
        canPlay.Should().BeTrue();
    }

    [Fact]
    public void RedJoker_ShouldNotMatch_BlackCard()
    {
        // Arrange
        var redJoker = Models.Card.NewRedJoker();
        var blackCard = Models.Card.NewCard(Suit.Spades, Rank.King);

        // Act
        var canPlay = Models.Player.CanPlayCardOn(redJoker, blackCard, inAttackChain: false);

        // Assert
        canPlay.Should().BeFalse();
    }

    [Fact]
    public void BlackJoker_ShouldNotMatch_RedCard()
    {
        // Arrange
        var blackJoker = Models.Card.NewBlackJoker();
        var redCard = Models.Card.NewCard(Suit.Hearts, Rank.King);

        // Act
        var canPlay = Models.Player.CanPlayCardOn(blackJoker, redCard, inAttackChain: false);

        // Assert
        canPlay.Should().BeFalse();
    }

    [Fact]
    public void Joker_ShouldMatch_OtherJoker()
    {
        // Arrange
        var redJoker = Models.Card.NewRedJoker();
        var blackJoker = Models.Card.NewBlackJoker();

        // Act
        var redOnBlack = Models.Player.CanPlayCardOn(redJoker, blackJoker, inAttackChain: false);
        var blackOnRed = Models.Player.CanPlayCardOn(blackJoker, redJoker, inAttackChain: false);

        // Assert
        redOnBlack.Should().BeTrue();
        blackOnRed.Should().BeTrue();
    }
}