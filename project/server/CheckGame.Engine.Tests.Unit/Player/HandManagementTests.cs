using CheckGame.Engine.Models;
using FluentAssertions;

namespace CheckGame.Engine.Tests.Unit.Player;

public class HandManagementTests
{
    [Fact]
    public void AddToHand_ShouldAddCard_WhenCardIsProvided()
    {
        // Arrange
        var player = Models.Player.New("player1");
        var card = Models.Card.NewCard(Suit.Hearts, Rank.Ace);

        // Act
        player.AddToHand(card);

        // Assert
        player.Hand.Should().Contain(card);
        player.HandSize().Should().Be(1);
        player.HasEmptyHand().Should().BeFalse();
    }

    [Fact]
    public void AddToHand_ShouldThrowException_WhenCardIsNull()
    {
        // Arrange
        var player = Models.Player.New("player1");

        // Act
        var act = () => player.AddToHand(null!);

        // Assert
        act.Should().Throw<ArgumentNullException>()
           .WithParameterName("card");
    }

    [Fact]
    public void AddCardsToHand_ShouldAddMultipleCards()
    {
        // Arrange
        var player = Models.Player.New("player1");
        var cards = new[]
        {
            Models.Card.NewCard(Suit.Hearts, Rank.Ace),
            Models.Card.NewCard(Suit.Spades, Rank.King),
            Models.Card.NewCard(Suit.Diamonds, Rank.Queen)
        };

        // Act
        player.AddCardsToHand(cards);

        // Assert
        player.Hand.Should().Contain(cards);
        player.HandSize().Should().Be(3);
    }

    [Fact]
    public void AddCardsToHand_ShouldThrowException_WhenCardsIsNull()
    {
        // Arrange
        var player = Models.Player.New("player1");

        // Act
        var act = () => player.AddCardsToHand(null!);

        // Assert
        act.Should().Throw<ArgumentNullException>()
           .WithParameterName("cards");
    }

    [Fact]
    public void RemoveFromHand_ShouldRemoveCard_WhenCardExists()
    {
        // Arrange
        var player = Models.Player.New("player1");
        var card1 = Models.Card.NewCard(Suit.Hearts, Rank.Ace);
        var card2 = Models.Card.NewCard(Suit.Spades, Rank.King);
        player.AddCardsToHand(new[] { card1, card2 });

        // Act
        var (removedCard, success) = player.RemoveFromHand(card1);

        // Assert
        success.Should().BeTrue();
        removedCard.Should().Be(card1);
        player.Hand.Should().NotContain(card1);
        player.Hand.Should().Contain(card2);
        player.HandSize().Should().Be(1);
    }

    [Fact]
    public void RemoveFromHand_ShouldReturnFailure_WhenCardDoesNotExist()
    {
        // Arrange
        var player = Models.Player.New("player1");
        var existingCard = Models.Card.NewCard(Suit.Hearts, Rank.Ace);
        var nonExistentCard = Models.Card.NewCard(Suit.Spades, Rank.King);
        player.AddToHand(existingCard);

        // Act
        var (removedCard, success) = player.RemoveFromHand(nonExistentCard);

        // Assert
        success.Should().BeFalse();
        removedCard.Should().Be(default);
        player.Hand.Should().Contain(existingCard);
        player.HandSize().Should().Be(1);
    }

    [Fact]
    public void RemoveFromHand_ShouldThrowException_WhenCardIsNull()
    {
        // Arrange
        var player = Models.Player.New("player1");

        // Act
        var act = () => player.RemoveFromHand(null!);

        // Assert
        act.Should().Throw<ArgumentNullException>()
           .WithParameterName("card");
    }

    [Fact]
    public void HasCard_ShouldReturnTrue_WhenCardExists()
    {
        // Arrange
        var player = Models.Player.New("player1");
        var card = Models.Card.NewCard(Suit.Hearts, Rank.Ace);
        player.AddToHand(card);

        // Act & Assert
        player.HasCard(card).Should().BeTrue();
    }

    [Fact]
    public void HasCard_ShouldReturnFalse_WhenCardDoesNotExist()
    {
        // Arrange
        var player = Models.Player.New("player1");
        var existingCard = Models.Card.NewCard(Suit.Hearts, Rank.Ace);
        var nonExistentCard = Models.Card.NewCard(Suit.Spades, Rank.King);
        player.AddToHand(existingCard);

        // Act & Assert
        player.HasCard(nonExistentCard).Should().BeFalse();
    }

    [Fact]
    public void HasCard_ShouldThrowException_WhenCardIsNull()
    {
        // Arrange
        var player = Models.Player.New("player1");

        // Act
        var act = () => player.HasCard(null!);

        // Assert
        act.Should().Throw<ArgumentNullException>()
           .WithParameterName("card");
    }

    [Fact]
    public void ClearHand_ShouldRemoveAllCards()
    {
        // Arrange
        var player = Models.Player.New("player1");
        var cards = new[]
        {
            Models.Card.NewCard(Suit.Hearts, Rank.Ace),
            Models.Card.NewCard(Suit.Spades, Rank.King)
        };
        player.AddCardsToHand(cards);

        // Act
        player.ClearHand();

        // Assert
        player.Hand.Should().BeEmpty();
        player.HandSize().Should().Be(0);
        player.HasEmptyHand().Should().BeTrue();
    }

    [Fact]
    public void Clone_ShouldCreateExactCopy()
    {
        // Arrange
        var originalPlayer = Models.Player.New("player1");
        var cards = new[]
        {
            Models.Card.NewCard(Suit.Hearts, Rank.Ace),
            Models.Card.NewCard(Suit.Spades, Rank.King)
        };
        originalPlayer.AddCardsToHand(cards);

        // Act
        var clonedPlayer = originalPlayer.Clone();

        // Assert
        clonedPlayer.Id.Should().Be(originalPlayer.Id);
        clonedPlayer.Hand.Should().Equal(originalPlayer.Hand);
        clonedPlayer.HandSize().Should().Be(originalPlayer.HandSize());

        // Verify they are separate instances
        clonedPlayer.Should().NotBeSameAs(originalPlayer);
    }

    [Fact]
    public void Clone_ShouldCreateIndependentCopy()
    {
        // Arrange
        var originalPlayer = Models.Player.New("player1");
        var card = Models.Card.NewCard(Suit.Hearts, Rank.Ace);
        originalPlayer.AddToHand(card);

        // Act
        var clonedPlayer = originalPlayer.Clone();
        clonedPlayer.AddToHand(Models.Card.NewCard(Suit.Spades, Rank.King));

        // Assert
        originalPlayer.HandSize().Should().Be(1);
        clonedPlayer.HandSize().Should().Be(2);
    }
}