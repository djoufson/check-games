# WebSocket Event Specifications

## Overview
The Check-Game uses WebSocket connections for real-time communication between clients and server. All events are JSON-formatted and include the complete game state to ensure client synchronization.

## Connection Flow

### 1. Connection Establishment
```javascript
// Client connects with session token
const ws = new WebSocket(`wss://api.checkgame.com/game?sessionToken=${token}`);

// Server responds with connection acknowledgment
{
  "type": "connection_established",
  "data": {
    "playerId": "uuid",
    "sessionId": "uuid",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

### 2. Authentication
```javascript
// Server sends current session state after successful auth
{
  "type": "session_state",
  "data": {
    "sessionId": "uuid",
    "players": [...],
    "currentGame": {...} | null,
    "tournament": {...}
  }
}
```

## Event Structure

### Base Event Format
```typescript
interface BaseEvent {
  type: string;
  data: any;
  timestamp: string;
  sessionId: string;
  gameId?: string; // Present for game-specific events
}
```

## Session Events

### Player Joined Session
```javascript
{
  "type": "player_joined_session",
  "data": {
    "player": {
      "id": "uuid",
      "username": "string",
      "isAnonymous": boolean,
      "joinedAt": "timestamp"
    },
    "sessionState": {
      "currentPlayers": number,
      "maxPlayers": number,
      "canStartGame": boolean
    }
  },
  "timestamp": "2024-01-15T10:30:00Z",
  "sessionId": "uuid"
}
```

### Player Left Session
```javascript
{
  "type": "player_left_session",
  "data": {
    "playerId": "uuid",
    "reason": "voluntary" | "disconnect" | "kicked",
    "sessionState": {
      "currentPlayers": number,
      "playersRemaining": ["uuid"]
    }
  },
  "timestamp": "2024-01-15T10:30:00Z",
  "sessionId": "uuid"
}
```

### Session Status Changed
```javascript
{
  "type": "session_status_changed",
  "data": {
    "oldStatus": "waiting" | "active" | "completed",
    "newStatus": "waiting" | "active" | "completed",
    "reason": "string"
  },
  "timestamp": "2024-01-15T10:30:00Z",
  "sessionId": "uuid"
}
```

## Game Events

### Game Started
```javascript
{
  "type": "game_started",
  "data": {
    "gameId": "uuid",
    "gameNumber": number,
    "players": [
      {
        "id": "uuid",
        "username": "string",
        "handSize": number,
        "playOrder": number,
        "isCurrentPlayer": boolean
      }
    ],
    "gameState": {
      "currentCard": {
        "suit": "spades" | "hearts" | "diamonds" | "clubs",
        "rank": "A" | "2"-"10" | "J" | "Q" | "K" | "Joker",
        "color": "red" | "black"
      },
      "currentPlayerId": "uuid",
      "drawPileSize": number,
      "discardPileSize": number,
      "turnDirection": 1 | -1,
      "attackStack": number,
      "chosenSuit": "spades" | "hearts" | "diamonds" | "clubs" | null
    },
    "playerHand": [
      {
        "suit": "spades" | "hearts" | "diamonds" | "clubs",
        "rank": "A" | "2"-"10" | "J" | "Q" | "K" | "Joker",
        "color": "red" | "black"
      }
    ]
  },
  "timestamp": "2024-01-15T10:30:00Z",
  "sessionId": "uuid",
  "gameId": "uuid"
}
```

### Game State Update
```javascript
{
  "type": "game_state_update",
  "data": {
    "gameState": {
      "currentCard": {
        "suit": "spades" | "hearts" | "diamonds" | "clubs",
        "rank": "A" | "2"-"10" | "J" | "Q" | "K" | "Joker",
        "color": "red" | "black"
      },
      "currentPlayerId": "uuid",
      "drawPileSize": number,
      "discardPileSize": number,
      "turnDirection": 1 | -1,
      "attackStack": number,
      "chosenSuit": "spades" | "hearts" | "diamonds" | "clubs" | null,
      "skipNextPlayer": boolean
    },
    "players": [
      {
        "id": "uuid",
        "handSize": number,
        "isCurrentPlayer": boolean,
        "isEliminated": boolean
      }
    ],
    "playerHand": [...], // Only for the receiving player
    "lastAction": {
      "type": "play_card" | "draw_card" | "skip_turn",
      "playerId": "uuid",
      "card": {...} | null,
      "cardsDrawn": number
    }
  },
  "timestamp": "2024-01-15T10:30:00Z",
  "sessionId": "uuid",
  "gameId": "uuid"
}
```

### Player Action Events

#### Card Played
```javascript
{
  "type": "card_played",
  "data": {
    "playerId": "uuid",
    "card": {
      "suit": "spades" | "hearts" | "diamonds" | "clubs",
      "rank": "A" | "2"-"10" | "J" | "Q" | "K" | "Joker",
      "color": "red" | "black"
    },
    "chosenSuit": "spades" | "hearts" | "diamonds" | "clubs" | null,
    "isSpecialCard": boolean,
    "effect": {
      "type": "skip" | "draw" | "reverse" | "wild" | "transparent",
      "targetPlayerId": "uuid" | null,
      "cardsToDrawNext": number,
      "attackStackAdded": number
    },
    "gameState": {...} // Complete updated game state
  },
  "timestamp": "2024-01-15T10:30:00Z",
  "sessionId": "uuid",
  "gameId": "uuid"
}
```

#### Card Drawn
```javascript
{
  "type": "card_drawn",
  "data": {
    "playerId": "uuid",
    "cardsDrawn": number,
    "reason": "cannot_play" | "attack_penalty" | "seven_effect" | "joker_effect",
    "drawnCard": {...} | null, // Only sent to the player who drew
    "gameState": {...} // Updated game state
  },
  "timestamp": "2024-01-15T10:30:00Z",
  "sessionId": "uuid",
  "gameId": "uuid"
}
```

#### Turn Skipped
```javascript
{
  "type": "turn_skipped",
  "data": {
    "playerId": "uuid",
    "reason": "ace_effect" | "timeout" | "voluntary",
    "nextPlayerId": "uuid",
    "gameState": {...}
  },
  "timestamp": "2024-01-15T10:30:00Z",
  "sessionId": "uuid",
  "gameId": "uuid"
}
```

#### Suit Chosen (Jack Effect)
```javascript
{
  "type": "suit_chosen",
  "data": {
    "playerId": "uuid",
    "chosenSuit": "spades" | "hearts" | "diamonds" | "clubs",
    "gameState": {...}
  },
  "timestamp": "2024-01-15T10:30:00Z",
  "sessionId": "uuid",
  "gameId": "uuid"
}
```

### Game Completion Events

#### Player Eliminated
```javascript
{
  "type": "player_eliminated",
  "data": {
    "playerId": "uuid",
    "remainingPlayers": ["uuid"],
    "eliminationReason": "last_with_cards" | "disconnected",
    "gameState": {...}
  },
  "timestamp": "2024-01-15T10:30:00Z",
  "sessionId": "uuid",
  "gameId": "uuid"
}
```

#### Game Finished
```javascript
{
  "type": "game_finished",
  "data": {
    "gameId": "uuid",
    "gameNumber": number,
    "winnerId": "uuid",
    "loserId": "uuid",
    "duration": "PT5M30S", // ISO 8601 duration
    "finalState": {
      "players": [
        {
          "id": "uuid",
          "finalHandSize": number,
          "placement": number // 1 = winner, 2 = second, etc.
        }
      ]
    },
    "tournamentState": {
      "eliminatedPlayers": ["uuid"],
      "remainingPlayers": ["uuid"],
      "nextGameReady": boolean
    }
  },
  "timestamp": "2024-01-15T10:30:00Z",
  "sessionId": "uuid",
  "gameId": "uuid"
}
```

### Tournament Events

#### Tournament Winner
```javascript
{
  "type": "tournament_finished",
  "data": {
    "winnerId": "uuid",
    "sessionId": "uuid",
    "totalGames": number,
    "finalRankings": [
      {
        "playerId": "uuid",
        "username": "string",
        "placement": number,
        "gamesWon": number,
        "gamesLost": number
      }
    ],
    "duration": "PT45M12S"
  },
  "timestamp": "2024-01-15T10:30:00Z",
  "sessionId": "uuid"
}
```

## Client-to-Server Events

### Play Card
```javascript
{
  "type": "play_card",
  "data": {
    "card": {
      "suit": "spades" | "hearts" | "diamonds" | "clubs",
      "rank": "A" | "2"-"10" | "J" | "Q" | "K" | "Joker"
    },
    "chosenSuit": "spades" | "hearts" | "diamonds" | "clubs" | null // For Jack cards
  }
}
```

### Draw Card
```javascript
{
  "type": "draw_card",
  "data": {}
}
```

### Choose Suit (Response to Jack)
```javascript
{
  "type": "choose_suit",
  "data": {
    "suit": "spades" | "hearts" | "diamonds" | "clubs"
  }
}
```

### Leave Game
```javascript
{
  "type": "leave_game",
  "data": {
    "reason": "voluntary" | "disconnect"
  }
}
```

## Error Events

### Invalid Action
```javascript
{
  "type": "invalid_action",
  "data": {
    "action": "string",
    "reason": "not_your_turn" | "invalid_card" | "game_not_active" | "card_not_in_hand",
    "message": "string"
  },
  "timestamp": "2024-01-15T10:30:00Z",
  "sessionId": "uuid",
  "gameId": "uuid"
}
```

### Connection Error
```javascript
{
  "type": "connection_error",
  "data": {
    "code": "AUTH_FAILED" | "SESSION_NOT_FOUND" | "RATE_LIMITED",
    "message": "string",
    "reconnect": boolean
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

## System Events

### Heartbeat
```javascript
// Client sends heartbeat every 30 seconds
{
  "type": "ping",
  "data": {}
}

// Server responds
{
  "type": "pong",
  "data": {
    "serverTime": "2024-01-15T10:30:00Z"
  }
}
```

### Reconnection
```javascript
{
  "type": "player_reconnected",
  "data": {
    "playerId": "uuid",
    "gameState": {...}, // Current complete game state
    "missedEvents": [...] // Events that occurred during disconnect
  },
  "timestamp": "2024-01-15T10:30:00Z",
  "sessionId": "uuid",
  "gameId": "uuid"
}
```

## Connection Management

### Connection States
- **Connecting**: Initial WebSocket connection
- **Connected**: WebSocket established, authentication pending  
- **Authenticated**: Successfully joined session
- **Playing**: Active in a game
- **Disconnected**: Connection lost
- **Reconnecting**: Attempting to reconnect

### Reconnection Strategy
1. Exponential backoff (1s, 2s, 4s, 8s, 16s, max 30s)
2. Maximum 10 retry attempts
3. Full game state resync on reconnection
4. Missed events replay for short disconnections

### Error Handling
- Invalid events are ignored with error response
- Malformed JSON triggers connection termination
- Rate limiting: 100 messages per minute per connection
- Automatic disconnect after 5 minutes of inactivity

## Security Considerations

### Authentication
- Session tokens validated on every connection
- Tokens expire and require refresh
- Anonymous players get temporary session tokens

### Validation
- All game actions validated server-side
- Card ownership verified before plays
- Turn order enforced strictly
- Game state transitions validated

### Rate Limiting
- Maximum 2 actions per second per player
- Heartbeat required every 60 seconds
- Connection terminated on violation

### Data Privacy
- Player hands only sent to respective players
- Sensitive game state hidden from eliminated players
- Chat messages filtered for inappropriate content