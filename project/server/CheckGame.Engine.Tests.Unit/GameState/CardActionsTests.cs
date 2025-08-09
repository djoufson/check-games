using CheckGame.Engine.Models;
using FluentAssertions;

namespace CheckGame.Engine.Tests.Unit.GameState;

public class CardActionsTests
{
    private Models.GameState CreateTestGameState()
    {
        var player1 = Models.Player.New("player1");
        player1.AddCardsToHand(new[]
        {
            Models.Card.NewCard(Suit.Hearts, Rank.King),
            Models.Card.NewCard(Suit.Spades, Rank.Ace),
            Models.Card.NewCard(Suit.Diamonds, Rank.Jack),
            Models.Card.NewCard(Suit.Clubs, Rank.Two)
        });

        var player2 = Models.Player.New("player2");
        player2.AddCardsToHand(new[]
        {
            Models.Card.NewCard(Suit.Hearts, Rank.Queen),
            Models.Card.NewCard(Suit.Spades, Rank.King)
        });

        var drawPile = Models.Deck.NewStandardDeck();
        var topCard = Models.Card.NewCard(Suit.Hearts, Rank.Ten);

        return new Models.GameState(
            [player1, player2],
            [player1.Id, player2.Id],
            player1.Id,
            Direction.Clockwise,
            drawPile,
            [topCard],
            topCard,
            false,
            0,
            Suit.Hearts,
            false
        );
    }

    [Fact]
    public void PlayCard_ShouldSucceed_WhenValidCardPlayed()
    {
        // Arrange
        var gameState = CreateTestGameState();
        var heartKing = Models.Card.NewCard(Suit.Hearts, Rank.King);

        // Act
        var result = gameState.PlayCard("player1", heartKing);

        // Assert
        result.Should().BeNull(); // Success
        gameState.TopCard.Should().Be(heartKing);
        gameState.DiscardPile.Should().Contain(heartKing);
        gameState.Players[0].HasCard(heartKing).Should().BeFalse();
    }

    [Fact]
    public void PlayCard_ShouldFail_WhenNotPlayersTurn()
    {
        // Arrange
        var gameState = CreateTestGameState();
        var heartQueen = Models.Card.NewCard(Suit.Hearts, Rank.Queen);

        // Act
        var result = gameState.PlayCard("player2", heartQueen);

        // Assert
        result.Should().Be("Not your turn");
    }

    [Fact]
    public void PlayCard_ShouldFail_WhenCardNotInHand()
    {
        // Arrange
        var gameState = CreateTestGameState();
        var nonExistentCard = Models.Card.NewCard(Suit.Hearts, Rank.Five);

        // Act
        var result = gameState.PlayCard("player1", nonExistentCard);

        // Assert
        result.Should().Be("Card not in hand");
    }

    [Fact]
    public void PlayCard_ShouldFail_WhenInvalidPlay()
    {
        // Arrange
        var gameState = CreateTestGameState();
        // Top card is Hearts Ten, try to play Clubs King (different suit and rank)
        var invalidCard = Models.Card.NewCard(Suit.Clubs, Rank.King);
        gameState.Players[0].AddToHand(invalidCard);

        // Act
        var result = gameState.PlayCard("player1", invalidCard);

        // Assert
        result.Should().Be("Invalid play");
    }

    [Fact]
    public void PlayCard_ShouldAdvanceTurn_AfterValidPlay()
    {
        // Arrange
        var gameState = CreateTestGameState();
        var heartKing = Models.Card.NewCard(Suit.Hearts, Rank.King);

        // Act
        gameState.PlayCard("player1", heartKing);

        // Assert
        gameState.CurrentPlayerId.Should().Be("player2");
    }

    [Fact]
    public void PlayCard_WithAce_ShouldSkipNextPlayer()
    {
        // Arrange
        var gameState = CreateTestGameState();
        var spadeAce = Models.Card.NewCard(Suit.Spades, Rank.Ace);

        // Change top card to make ace playable
        gameState.PlayCard("player1", spadeAce);

        // Assert - With only 2 players, skipping means current player plays again
        gameState.CurrentPlayerId.Should().Be("player1");
    }

    [Fact]
    public void PlayCard_WithJack_ShouldLockTurn()
    {
        // Arrange
        var gameState = CreateTestGameState();
        var diamondJack = Models.Card.NewCard(Suit.Diamonds, Rank.Jack);

        // Act
        gameState.PlayCard("player1", diamondJack);

        // Assert
        gameState.LockedTurn.Should().BeTrue();
        gameState.CurrentPlayerId.Should().Be("player1"); // Turn not advanced
    }

    [Fact]
    public void PlayCard_WithTransparentTwo_ShouldAlwaysBeValid()
    {
        // Arrange
        var gameState = CreateTestGameState();
        var clubsTwo = Models.Card.NewCard(Suit.Clubs, Rank.Two);

        // Act - Playing Two should always be valid regardless of top card
        var result = gameState.PlayCard("player1", clubsTwo);

        // Assert
        result.Should().BeNull(); // Success
        gameState.TopCard.Should().Be(clubsTwo);
    }

    [Fact]
    public void PlayCard_ShouldRemovePlayerFromActive_WhenHandBecomesEmpty()
    {
        // Arrange
        var gameState = CreateTestGameState();
        var player = gameState.Players[0];

        // Clear hand and add one matching card
        player.ClearHand();
        var lastCard = Models.Card.NewCard(Suit.Hearts, Rank.Queen);
        player.AddToHand(lastCard);

        // Act
        gameState.PlayCard("player1", lastCard);

        // Assert
        gameState.ActivePlayers.Should().NotContain("player1");
        player.HasEmptyHand().Should().BeTrue();
    }

    [Fact]
    public void DrawCard_ShouldAddCardToHand()
    {
        // Arrange
        var gameState = CreateTestGameState();
        var initialHandSize = gameState.Players[0].HandSize();

        // Act
        var result = gameState.DrawCard("player1");

        // Assert
        result.Should().BeNull(); // Success
        gameState.Players[0].HandSize().Should().Be(initialHandSize + 1);
    }

    [Fact]
    public void DrawCard_ShouldAdvanceTurn()
    {
        // Arrange
        var gameState = CreateTestGameState();

        // Act
        gameState.DrawCard("player1");

        // Assert
        gameState.CurrentPlayerId.Should().Be("player2");
    }

    [Fact]
    public void DrawCard_ShouldFail_WhenNotPlayersTurn()
    {
        // Arrange
        var gameState = CreateTestGameState();

        // Act
        var result = gameState.DrawCard("player2");

        // Assert
        result.Should().Be("Not your turn");
    }
}