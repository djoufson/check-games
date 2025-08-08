using CheckGame.Engine.Models;
using FluentAssertions;

namespace CheckGame.Engine.Tests.Unit.GameState;

public class SuitChangerTests
{
    private Models.GameState CreateTestGameState()
    {
        var player1 = Models.Player.New("player1");
        player1.AddCardsToHand(new[]
        {
            Models.Card.NewCard(Suit.Diamonds, Rank.Jack),
            Models.Card.NewCard(Suit.Hearts, Rank.King)
        });

        var player2 = Models.Player.New("player2");
        player2.AddCardsToHand(new[]
        {
            Models.Card.NewCard(Suit.Spades, Rank.Queen),
            Models.Card.NewCard(Suit.Clubs, Rank.Ace)
        });

        var drawPile = Models.Deck.NewStandardDeck();
        var topCard = Models.Card.NewCard(Suit.Hearts, Rank.Ten);

        return new Models.GameState(
            new List<Models.Player> { player1, player2 },
            new List<string> { player1.Id, player2.Id },
            player1.Id,
            Direction.Clockwise,
            drawPile,
            new List<Models.Card> { topCard },
            topCard,
            false,
            0,
            Suit.Hearts,
            false
        );
    }

    [Fact]
    public void PlayCard_WithJack_ShouldLockTurn()
    {
        // Arrange
        var gameState = CreateTestGameState();
        var diamondJack = Models.Card.NewCard(Suit.Diamonds, Rank.Jack);

        // Act
        var result = gameState.PlayCard("player1", diamondJack);

        // Assert
        result.Should().BeNull(); // Success
        gameState.LockedTurn.Should().BeTrue();
        gameState.CurrentPlayerId.Should().Be("player1"); // Turn should not advance
        gameState.TopCard.Should().Be(diamondJack);
    }

    [Fact]
    public void ChangeSuit_ShouldSucceed_WhenTurnIsLocked()
    {
        // Arrange
        var gameState = CreateTestGameState();
        var diamondJack = Models.Card.NewCard(Suit.Diamonds, Rank.Jack);

        // Play Jack first to lock turn
        gameState.PlayCard("player1", diamondJack);

        // Act
        var result = gameState.ChangeSuit("player1", Suit.Spades);

        // Assert
        result.Should().BeNull(); // Success
        gameState.LastActiveSuit.Should().Be(Suit.Spades);
        gameState.LockedTurn.Should().BeFalse();
        gameState.CurrentPlayerId.Should().Be("player2"); // Turn should advance
    }

    [Fact]
    public void ChangeSuit_ShouldFail_WhenTurnIsNotLocked()
    {
        // Arrange
        var gameState = CreateTestGameState();

        // Act - Try to change suit without playing Jack first
        var result = gameState.ChangeSuit("player1", Suit.Spades);

        // Assert
        result.Should().Be("Turn is not locked");
        gameState.LastActiveSuit.Should().Be(Suit.Hearts); // Should remain unchanged
    }

    [Fact]
    public void ChangeSuit_ShouldFail_WhenNotPlayersTurn()
    {
        // Arrange
        var gameState = CreateTestGameState();
        var diamondJack = Models.Card.NewCard(Suit.Diamonds, Rank.Jack);

        // Play Jack to lock turn
        gameState.PlayCard("player1", diamondJack);

        // Act - Try to change suit as wrong player
        var result = gameState.ChangeSuit("player2", Suit.Spades);

        // Assert
        result.Should().Be("Not your turn");
    }

    [Fact]
    public void ChangeSuit_ShouldFail_WithInvalidSuit()
    {
        // Arrange
        var gameState = CreateTestGameState();
        var diamondJack = Models.Card.NewCard(Suit.Diamonds, Rank.Jack);

        // Play Jack to lock turn
        gameState.PlayCard("player1", diamondJack);

        // Act - Try to change to Joker suit (invalid)
        var result = gameState.ChangeSuit("player1", Suit.Joker);

        // Assert
        result.Should().Be("Invalid suit");
    }

    [Fact]
    public void ChangeSuit_ShouldFail_WhenLastCardWasNotJack()
    {
        // Arrange
        var gameState = CreateTestGameState();

        // Manually lock turn without playing Jack
        gameState.LockTurn();

        // Act
        var result = gameState.ChangeSuit("player1", Suit.Spades);

        // Assert
        result.Should().Be("Suit can only be changed after playing a Jack");
    }

    [Theory]
    [InlineData(Suit.Spades)]
    [InlineData(Suit.Hearts)]
    [InlineData(Suit.Diamonds)]
    [InlineData(Suit.Clubs)]
    public void ChangeSuit_ShouldAcceptValidSuits(Suit newSuit)
    {
        // Arrange
        var gameState = CreateTestGameState();
        var diamondJack = Models.Card.NewCard(Suit.Diamonds, Rank.Jack);

        // Play Jack to lock turn
        gameState.PlayCard("player1", diamondJack);

        // Act
        var result = gameState.ChangeSuit("player1", newSuit);

        // Assert
        result.Should().BeNull(); // Success
        gameState.LastActiveSuit.Should().Be(newSuit);
    }

    [Fact]
    public void PlayCard_ShouldFail_WhenTurnIsLocked()
    {
        // Arrange
        var gameState = CreateTestGameState();
        var diamondJack = Models.Card.NewCard(Suit.Diamonds, Rank.Jack);
        var heartKing = Models.Card.NewCard(Suit.Hearts, Rank.King);

        // Play Jack to lock turn
        gameState.PlayCard("player1", diamondJack);

        // Act - Try to play another card while turn is locked
        var result = gameState.PlayCard("player1", heartKing);

        // Assert
        result.Should().Be("Turn is locked");
    }

    [Fact]
    public void JackEffect_ShouldWorkWithAnyJack()
    {
        // Arrange
        var gameState = CreateTestGameState();
        var heartsJack = Models.Card.NewCard(Suit.Hearts, Rank.Jack);
        gameState.Players[0].AddToHand(heartsJack);

        // Act
        var result = gameState.PlayCard("player1", heartsJack);

        // Assert
        result.Should().BeNull(); // Success
        gameState.LockedTurn.Should().BeTrue();
        gameState.TopCard.Should().Be(heartsJack);
    }
}