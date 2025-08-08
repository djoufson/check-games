using CheckGame.Engine.Models;
using FluentAssertions;

namespace CheckGame.Engine.Tests.Unit.Player;

public class PlayerCreationTests
{
    [Fact]
    public void New_ShouldCreatePlayerWithCorrectId()
    {
        // Arrange & Act
        var player = Models.Player.New("player1");

        // Assert
        player.Id.Should().Be("player1");
    }

    [Fact]
    public void New_ShouldCreatePlayerWithEmptyHand()
    {
        // Arrange & Act
        var player = Models.Player.New("player1");

        // Assert
        player.Hand.Should().BeEmpty();
        player.HandSize().Should().Be(0);
        player.HasEmptyHand().Should().BeTrue();
    }

    [Fact]
    public void Constructor_ShouldCreatePlayerWithCorrectId()
    {
        // Arrange & Act
        var player = new Models.Player("test-id");

        // Assert
        player.Id.Should().Be("test-id");
        player.Hand.Should().BeEmpty();
    }

    [Fact]
    public void Constructor_ShouldThrowException_WhenIdIsNull()
    {
        // Arrange & Act & Assert
        var act = () => new Models.Player(null!);

        act.Should().Throw<ArgumentNullException>()
           .WithParameterName("id");
    }

    [Fact]
    public void HandSize_ShouldReturnZero_ForNewPlayer()
    {
        // Arrange
        var player = Models.Player.New("player1");

        // Act & Assert
        player.HandSize().Should().Be(0);
    }

    [Fact]
    public void HasEmptyHand_ShouldReturnTrue_ForNewPlayer()
    {
        // Arrange
        var player = Models.Player.New("player1");

        // Act & Assert
        player.HasEmptyHand().Should().BeTrue();
    }
}