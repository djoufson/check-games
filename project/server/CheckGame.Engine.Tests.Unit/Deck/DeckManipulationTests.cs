using CheckGame.Engine.Models;
using FluentAssertions;

namespace CheckGame.Engine.Tests.Unit.Deck;

public class DeckManipulationTests
{
    [Fact]
    public void AddToBottom_ShouldAddCardToBottom()
    {
        // Arrange
        var existingCard = Models.Card.NewCard(Suit.Hearts, Rank.Ace);
        var newCard = Models.Card.NewCard(Suit.Spades, Rank.King);
        var deck = new Models.Deck(new[] { existingCard });

        // Act
        deck.AddToBottom(newCard);

        // Assert
        deck.Count().Should().Be(2);
        deck.Cards[0].Should().Be(existingCard);
        deck.Cards[1].Should().Be(newCard);
    }

    [Fact]
    public void AddToBottom_ShouldThrowException_WhenCardIsNull()
    {
        // Arrange
        var deck = new Models.Deck();

        // Act
        var act = () => deck.AddToBottom(null!);

        // Assert
        act.Should().Throw<ArgumentNullException>()
           .WithParameterName("card");
    }

    [Fact]
    public void AddToTop_ShouldAddCardToTop()
    {
        // Arrange
        var existingCard = Models.Card.NewCard(Suit.Hearts, Rank.Ace);
        var newCard = Models.Card.NewCard(Suit.Spades, Rank.King);
        var deck = new Models.Deck(new[] { existingCard });

        // Act
        deck.AddToTop(newCard);

        // Assert
        deck.Count().Should().Be(2);
        deck.Cards[0].Should().Be(newCard);
        deck.Cards[1].Should().Be(existingCard);
    }

    [Fact]
    public void AddToTop_ShouldThrowException_WhenCardIsNull()
    {
        // Arrange
        var deck = new Models.Deck();

        // Act
        var act = () => deck.AddToTop(null!);

        // Assert
        act.Should().Throw<ArgumentNullException>()
           .WithParameterName("card");
    }

    [Fact]
    public void AddManyToBottom_ShouldAddCardsToBottom()
    {
        // Arrange
        var existingCard = Models.Card.NewCard(Suit.Hearts, Rank.Ace);
        var newCards = new[]
        {
            Models.Card.NewCard(Suit.Spades, Rank.King),
            Models.Card.NewCard(Suit.Diamonds, Rank.Queen)
        };
        var deck = new Models.Deck(new[] { existingCard });

        // Act
        deck.AddManyToBottom(newCards);

        // Assert
        deck.Count().Should().Be(3);
        deck.Cards[0].Should().Be(existingCard);
        deck.Cards[1].Should().Be(newCards[0]);
        deck.Cards[2].Should().Be(newCards[1]);
    }

    [Fact]
    public void AddManyToBottom_ShouldThrowException_WhenCardsIsNull()
    {
        // Arrange
        var deck = new Models.Deck();

        // Act
        var act = () => deck.AddManyToBottom(null!);

        // Assert
        act.Should().Throw<ArgumentNullException>()
           .WithParameterName("cards");
    }

    [Fact]
    public void Clear_ShouldRemoveAllCards()
    {
        // Arrange
        var deck = Models.Deck.NewStandardDeck();

        // Act
        deck.Clear();

        // Assert
        deck.Count().Should().Be(0);
        deck.IsEmpty().Should().BeTrue();
    }

    [Fact]
    public void Clone_ShouldCreateExactCopy()
    {
        // Arrange
        var originalDeck = Models.Deck.NewStandardDeck();

        // Act
        var clonedDeck = originalDeck.Clone();

        // Assert
        clonedDeck.Count().Should().Be(originalDeck.Count());
        clonedDeck.Cards.Should().Equal(originalDeck.Cards);
        
        // Verify they are separate instances
        clonedDeck.Should().NotBeSameAs(originalDeck);
        clonedDeck.Cards.Should().NotBeSameAs(originalDeck.Cards);
    }

    [Fact]
    public void Clone_ShouldCreateIndependentCopy()
    {
        // Arrange
        var originalDeck = new Models.Deck(new[] 
        { 
            Models.Card.NewCard(Suit.Hearts, Rank.Ace) 
        });

        // Act
        var clonedDeck = originalDeck.Clone();
        clonedDeck.AddToBottom(Models.Card.NewCard(Suit.Spades, Rank.King));

        // Assert
        originalDeck.Count().Should().Be(1);
        clonedDeck.Count().Should().Be(2);
    }
}