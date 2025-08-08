using CheckGame.Engine.Models;
using FluentAssertions;

namespace CheckGame.Engine.Tests.Unit.GameState;

public class StateCreationTests
{
    [Fact]
    public void New_ShouldCreateGameState_WithValidPlayerIds()
    {
        // Arrange
        var playerIds = new List<string> { "player1", "player2", "player3" };

        // Act
        var gameState = Models.GameState.New(playerIds);

        // Assert
        gameState.Should().NotBeNull();
        gameState.Players.Should().HaveCount(3);
        gameState.ActivePlayers.Should().HaveCount(3);
        gameState.CurrentPlayerId.Should().Be("player1");
        gameState.Direction.Should().Be(Direction.Clockwise);
    }

    [Fact]
    public void New_ShouldThrowException_WhenLessThanTwoPlayers()
    {
        // Arrange
        var playerIds = new List<string> { "player1" };

        // Act
        var act = () => Models.GameState.New(playerIds);

        // Assert
        act.Should().Throw<ArgumentException>()
           .WithMessage("At least 2 players are required*")
           .WithParameterName("playerIds");
    }

    [Fact]
    public void New_ShouldThrowException_WhenPlayerIdsIsNull()
    {
        // Act
        var act = () => Models.GameState.New(null!);

        // Assert
        act.Should().Throw<ArgumentNullException>()
           .WithParameterName("playerIds");
    }

    [Fact]
    public void New_ShouldDealInitialCards_ToAllPlayers()
    {
        // Arrange
        var playerIds = new List<string> { "player1", "player2" };
        var options = new GameOptions { InitialCards = 5 };

        // Act
        var gameState = Models.GameState.New(playerIds, options);

        // Assert
        foreach (var player in gameState.Players)
        {
            player.HandSize().Should().Be(5);
        }
    }

    [Fact]
    public void New_ShouldSetTopCard_FromDiscardPile()
    {
        // Arrange
        var playerIds = new List<string> { "player1", "player2" };

        // Act
        var gameState = Models.GameState.New(playerIds);

        // Assert
        gameState.TopCard.Should().NotBeNull();
        gameState.DiscardPile.Should().HaveCount(1);
        gameState.DiscardPile.First().Should().Be(gameState.TopCard);
    }

    [Fact]
    public void New_ShouldNotStartWithWildCardOnTop()
    {
        // Arrange
        var playerIds = new List<string> { "player1", "player2" };

        // Act
        var gameState = Models.GameState.New(playerIds);

        // Assert
        gameState.TopCard.IsWildCard().Should().BeFalse();
    }

    [Fact]
    public void New_ShouldSetLastActiveSuit_ToTopCardSuit()
    {
        // Arrange
        var playerIds = new List<string> { "player1", "player2" };

        // Act
        var gameState = Models.GameState.New(playerIds);

        // Assert
        gameState.LastActiveSuit.Should().Be(gameState.TopCard.Suit);
    }

    [Fact]
    public void New_ShouldInitializeWithCorrectDefaults()
    {
        // Arrange
        var playerIds = new List<string> { "player1", "player2" };

        // Act
        var gameState = Models.GameState.New(playerIds);

        // Assert
        gameState.InAttackChain.Should().BeFalse();
        gameState.AttackAmount.Should().Be(0);
        gameState.LockedTurn.Should().BeFalse();
        gameState.DrawPile.Should().NotBeNull();
        gameState.DrawPile.Count().Should().BeGreaterThan(0);
    }

    [Fact]
    public void New_WithFixedSeed_ShouldProduceDeterministicResults()
    {
        // Arrange
        var playerIds = new List<string> { "player1", "player2" };
        var options = new GameOptions { RandomSeed = 42 };

        // Act
        var gameState1 = Models.GameState.New(playerIds, options);
        var gameState2 = Models.GameState.New(playerIds, options);

        // Assert
        gameState1.TopCard.Should().Be(gameState2.TopCard);
        gameState1.Players[0].Hand.Should().Equal(gameState2.Players[0].Hand);
        gameState1.Players[1].Hand.Should().Equal(gameState2.Players[1].Hand);
    }
}