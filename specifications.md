# Check-Game Rules

Check-game is a fast-paced card game inspired by UNO, but played with a standard poker deck (including jokers) and unique rules. The goal is to be the first to empty your hand; the last player with cards loses.

---

## 1. Components
- **Deck:** Standard 54-card poker deck (52 cards + 2 jokers)
- **Players:** 2 or more

## 2. Setup
- Shuffle the deck.
- Deal an equal number of cards to each player (e.g., 7 cards each; adjust as desired).
- Place the remaining deck face down as the draw pile (bank).
- Turn the top card of the draw pile face up to start the discard pile.

## 3. Objective
- There is no scoring.
- When a player empties their hand, they exit the game.
- Play continues until only one player remains; this player is the loser.

## 4. Valid Moves
- On your turn, play a card that matches the top discard by **suit (color)** or **rank (number/face)**.
  - Example: 2♠ on 2♦ (same rank), or 2♠ on 6♠ (same suit).
- Jokers can be played on any card of the same color (red/black) or on another joker.
- The 2 card is transparent: it can be played on any card (except during an attack chain).
- Jack can be played on any card, regardless of suit or rank (except during an attack chain).
- If you cannot play, draw one card from the bank. Your turn ends immediately; you cannot play the drawn card in the same turn.

## 5. Special Cards & Effects
- **Ace:** Skips the next player's turn. If only two players remain, the Ace player plays again.
- **Wild Cards (7s and Jokers):**
  - 7: Next player must draw 2 cards (unless they counter with another 7 or joker).
  - Joker: Next player must draw 4 cards (unless they counter with another 7 or joker).
  - Wild card effects stack: If multiple wilds are played in succession, the last attacked player draws the total sum.
- **Jack:** Can be played on any card like the transparent 2 (except during an attack chain). When played, the player chooses the next suit (spades, hearts, diamonds, clubs).
- **2:** Transparent card; can be played on any card except during an attack chain (cannot be used to counter wild card attacks).

## 6. Attack Chains
- If attacked with a wild card (7 or joker), the next player can defend by playing another wild card (7 or joker). The penalty accumulates until a player cannot defend and must draw the total.
- Neither transparent 2s nor Jacks can be used to counter wild card attacks.

## 7. End of Game
- When a player has no cards left, they exit the game.
- The last player remaining with cards is the loser.

## 8. Implementation Notes
- Represent cards with `suit`, `rank`, and `color` (red/black).
- Track player hands, draw/discard piles, and play direction.
- Implement special card effects and attack chains.
- Handle suit change (Jack), skips (Ace), and transparent 2s.
- No scoring system is needed.

## 9. Additional Rule
- If the bank (draw pile) is empty, shuffle the discard pile except for the top card to refill the bank.

---

**Reference:** Custom rules based on UNO and poker deck mechanics. 