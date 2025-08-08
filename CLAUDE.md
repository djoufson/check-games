# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a card game implementation of "Check-Game" - a fast-paced game inspired by UNO but played with a standard 54-card poker deck (52 cards + 2 jokers). The game specifications are fully defined in `specifications.md`.

## Game Architecture

The game follows these core concepts from the specifications:
- **Card System**: Cards have `suit`, `rank`, and `color` (red/black) properties
- **Game State**: Track player hands, draw/discard piles, and play direction
- **Special Cards**: Implement effects for Ace (skip), 7s/Jokers (attack cards), Jack (suit change), and 2 (transparent)
- **Attack Chains**: Wild cards (7s and Jokers) can be countered by other wild cards, stacking penalties
- **Win Condition**: Last player with cards loses (no scoring system)

## Key Game Rules to Implement

- Valid moves: match by suit/color or rank, with special handling for transparent 2s and Jacks
- Jokers can only be played on same color cards or other jokers
- Attack chains prevent using 2s or Jacks as counters
- Bank refill: when draw pile is empty, shuffle discard pile (except top card)
- Player elimination: players exit when hand is empty, last remaining player loses

## Development Notes

This appears to be a new project with only specifications defined. When implementing:
- Focus on the card representation system first (suit, rank, color)
- Implement game state management for turns, hands, and piles  
- Handle special card effects and attack chain logic carefully
- No scoring system is needed - only track player elimination