using CheckGame.Engine.Models;
using FluentAssertions;

namespace CheckGame.Engine.Tests.Unit.GameState;

public class AttackChainTests
{
    private Models.GameState CreateTestGameState()
    {
        var player1 = Models.Player.New("player1");
        player1.AddCardsToHand(new[]
        {
            Models.Card.NewCard(Suit.Hearts, Rank.Seven), // Wild (+2)
            Models.Card.NewRedJoker()                     // Wild (+4)
        });

        var player2 = Models.Player.New("player2");
        player2.AddCardsToHand(new[]
        {
            Models.Card.NewCard(Suit.Spades, Rank.Seven), // Wild (+2)
            Models.Card.NewCard(Suit.Clubs, Rank.King)    // Regular card
        });

        var drawPile = Models.Deck.NewStandardDeck();
        var topCard = Models.Card.NewCard(Suit.Hearts, Rank.Queen);

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
    public void PlayCard_ShouldStartAttackChain_WhenPlayingWildCard()
    {
        // Arrange
        var gameState = CreateTestGameState();
        var sevenCard = Models.Card.NewCard(Suit.Hearts, Rank.Seven);

        // Act
        var result = gameState.PlayCard("player1", sevenCard);

        // Assert
        result.Should().BeNull(); // Success
        gameState.InAttackChain.Should().BeTrue();
        gameState.AttackAmount.Should().Be(2);
    }

    [Fact]
    public void PlayCard_ShouldAccumulateAttackAmount_WhenChaining()
    {
        // Arrange
        var gameState = CreateTestGameState();
        var sevenCard = Models.Card.NewCard(Suit.Hearts, Rank.Seven);
        var jokerCard = Models.Card.NewRedJoker();

        // Start attack chain with seven
        gameState.PlayCard("player1", sevenCard);

        // Player 2 should now be able to defend with seven
        var player2SevenCard = Models.Card.NewCard(Suit.Spades, Rank.Seven);

        // Act
        var result = gameState.PlayCard("player2", player2SevenCard);

        // Assert
        result.Should().BeNull(); // Success
        gameState.InAttackChain.Should().BeTrue();
        gameState.AttackAmount.Should().Be(4); // 2 + 2
    }

    [Fact]
    public void PlayCard_ShouldRejectNonWildCard_DuringAttackChain()
    {
        // Arrange
        var gameState = CreateTestGameState();
        var sevenCard = Models.Card.NewCard(Suit.Hearts, Rank.Seven);
        var kingCard = Models.Card.NewCard(Suit.Clubs, Rank.King);

        // Start attack chain
        gameState.PlayCard("player1", sevenCard);

        // Act - Try to play non-wild card
        var result = gameState.PlayCard("player2", kingCard);

        // Assert
        result.Should().Be("Must play a wild card to defend against an attack");
        gameState.InAttackChain.Should().BeTrue();
        gameState.AttackAmount.Should().Be(2);
    }

    [Fact]
    public void DrawCard_ShouldEndAttackChain_AndDrawCorrectAmount()
    {
        // Arrange
        var gameState = CreateTestGameState();
        var sevenCard = Models.Card.NewCard(Suit.Hearts, Rank.Seven);
        var initialHandSize = gameState.Players[1].HandSize();

        // Start attack chain
        gameState.PlayCard("player1", sevenCard);

        // Act - Player 2 draws instead of defending
        var result = gameState.DrawCard("player2");

        // Assert
        result.Should().BeNull(); // Success
        gameState.InAttackChain.Should().BeFalse();
        gameState.AttackAmount.Should().Be(0);
        gameState.Players[1].HandSize().Should().Be(initialHandSize + 2); // Drew 2 cards
    }

    [Fact]
    public void PlayCard_ShouldWorkWithJokerDefense()
    {
        // Arrange
        var gameState = CreateTestGameState();
        var sevenCard = Models.Card.NewCard(Suit.Hearts, Rank.Seven);

        // Add black joker to player 2
        var player2 = gameState.Players[1];
        player2.AddToHand(Models.Card.NewBlackJoker());

        // Start attack chain
        gameState.PlayCard("player1", sevenCard);

        // Act - Defend with joker
        var result = gameState.PlayCard("player2", Models.Card.NewBlackJoker());

        // Assert
        result.Should().BeNull(); // Success
        gameState.InAttackChain.Should().BeTrue();
        gameState.AttackAmount.Should().Be(6); // 2 + 4
    }

    [Fact]
    public void AttackChain_ShouldAdvanceTurn_WhenWildCardPlayed()
    {
        // Arrange
        var gameState = CreateTestGameState();
        var sevenCard = Models.Card.NewCard(Suit.Hearts, Rank.Seven);

        // Act
        gameState.PlayCard("player1", sevenCard);

        // Assert
        gameState.CurrentPlayerId.Should().Be("player2");
    }

    [Theory]
    [InlineData(2)]
    // [InlineData(Rank.Seven, 4)] // After chaining two sevens
    public void AttackChain_ShouldAccumulateCorrectly(int expectedFinalAmount)
    {
        // Arrange
        var gameState = CreateTestGameState();
        var firstCard = Models.Card.NewCard(Suit.Hearts, Rank.Seven);

        // Act
        gameState.PlayCard("player1", firstCard);

        if (expectedFinalAmount > 2)
        {
            var secondCard = Models.Card.NewCard(Suit.Spades, Rank.Seven);
            gameState.PlayCard("player2", secondCard);
        }

        // Assert
        gameState.AttackAmount.Should().Be(expectedFinalAmount);
    }
}