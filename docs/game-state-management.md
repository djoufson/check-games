# Game State Management Plan

## Overview
The Check-Game implements a server-authoritative game state system with event-driven updates. The server maintains the definitive game state while clients maintain local representations synchronized through WebSocket events.

## Game State Architecture

### State Hierarchy
```
Session State
├── Session Metadata (name, players, status)
├── Tournament State (eliminated players, rankings)
└── Game State
    ├── Game Metadata (id, status, players)
    ├── Deck State (draw pile, discard pile)
    ├── Turn State (current player, direction, effects)
    └── Player States (hands, eliminated status)
```

## Server-Side State Management

### Game State Structure
```typescript
interface GameState {
  // Game identification
  gameId: string;
  sessionId: string;
  gameNumber: number;
  status: 'waiting' | 'active' | 'completed';
  
  // Player management
  players: GamePlayer[];
  currentPlayerId: string;
  turnDirection: 1 | -1; // 1 = clockwise, -1 = counter-clockwise
  playOrder: string[]; // Array of player IDs in turn order
  
  // Card state
  drawPile: Card[];
  discardPile: Card[];
  currentCard: Card;
  
  // Special effects
  attackStack: number; // Accumulated penalty from 7s and Jokers
  chosenSuit: Suit | null; // Suit chosen by Jack card
  skipNextPlayer: boolean; // Skip effect from Ace
  
  // Game flow
  startedAt: Date;
  completedAt?: Date;
  winnerId?: string;
  loserId?: string;
  
  // Metadata
  lastUpdated: Date;
  version: number; // For conflict resolution
}

interface GamePlayer {
  id: string;
  sessionPlayerId: string;
  hand: Card[];
  handSize: number; // Public info
  isEliminated: boolean;
  eliminatedAt?: Date;
  playOrder: number;
}

interface Card {
  suit: 'spades' | 'hearts' | 'diamonds' | 'clubs';
  rank: 'A' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' | '10' | 'J' | 'Q' | 'K' | 'Joker';
  color: 'red' | 'black';
  id: string; // Unique identifier for this card instance
}
```

### State Transitions

#### Game Initialization
```typescript
class GameEngine {
  initializeGame(sessionId: string, players: SessionPlayer[]): GameState {
    const deck = this.createShuffledDeck();
    const gameState: GameState = {
      gameId: generateUUID(),
      sessionId,
      gameNumber: this.getNextGameNumber(sessionId),
      status: 'waiting',
      players: this.dealCardsToPlayers(players, deck, 7),
      currentPlayerId: players[0].id,
      turnDirection: 1,
      playOrder: players.map(p => p.id),
      drawPile: deck.slice(players.length * 7 + 1),
      discardPile: [deck[players.length * 7]],
      currentCard: deck[players.length * 7],
      attackStack: 0,
      chosenSuit: null,
      skipNextPlayer: false,
      startedAt: new Date(),
      lastUpdated: new Date(),
      version: 1
    };
    
    return this.validateGameState(gameState);
  }
}
```

#### Action Processing
```typescript
interface GameAction {
  type: 'play_card' | 'draw_card' | 'choose_suit' | 'skip_turn';
  playerId: string;
  card?: Card;
  chosenSuit?: Suit;
  timestamp: Date;
}

class GameEngine {
  processAction(gameState: GameState, action: GameAction): GameStateResult {
    // Validate action
    const validation = this.validateAction(gameState, action);
    if (!validation.valid) {
      return { success: false, error: validation.error };
    }
    
    // Create new state
    const newState = { ...gameState, version: gameState.version + 1 };
    
    // Process specific action
    switch (action.type) {
      case 'play_card':
        return this.processPlayCard(newState, action);
      case 'draw_card':
        return this.processDrawCard(newState, action);
      case 'choose_suit':
        return this.processChooseSuit(newState, action);
      case 'skip_turn':
        return this.processSkipTurn(newState, action);
    }
  }
  
  private processPlayCard(gameState: GameState, action: GameAction): GameStateResult {
    const player = this.getPlayer(gameState, action.playerId);
    const card = action.card!;
    
    // Remove card from player's hand
    player.hand = player.hand.filter(c => c.id !== card.id);
    player.handSize = player.hand.length;
    
    // Add to discard pile
    gameState.discardPile.push(card);
    gameState.currentCard = card;
    
    // Process card effects
    this.processCardEffects(gameState, card, action.playerId);
    
    // Check for game end conditions
    this.checkGameEndConditions(gameState);
    
    // Update turn
    this.advanceTurn(gameState);
    
    gameState.lastUpdated = new Date();
    
    return { success: true, gameState, events: this.generateEvents(gameState, action) };
  }
}
```

### Card Effects Processing
```typescript
class CardEffectsProcessor {
  processCardEffects(gameState: GameState, card: Card, playerId: string): void {
    switch (card.rank) {
      case 'A': // Skip next player
        gameState.skipNextPlayer = true;
        break;
        
      case '7': // Next player draws 2 (or counter)
        gameState.attackStack += 2;
        break;
        
      case 'Joker': // Next player draws 4 (or counter)
        gameState.attackStack += 4;
        break;
        
      case 'J': // Choose suit
        // chosenSuit will be set when player responds with choose_suit action
        gameState.chosenSuit = null; // Reset until chosen
        break;
        
      case '2': // Transparent card - no special effect
        break;
        
      default:
        // Regular card - no special effects
        break;
    }
  }
  
  canCounterAttack(gameState: GameState, card: Card): boolean {
    return gameState.attackStack > 0 && 
           (card.rank === '7' || card.rank === 'Joker');
  }
  
  isValidPlay(gameState: GameState, card: Card): boolean {
    const current = gameState.currentCard;
    
    // During attack chain, only wild cards can be played
    if (gameState.attackStack > 0) {
      return card.rank === '7' || card.rank === 'Joker';
    }
    
    // Transparent 2 can be played on anything
    if (card.rank === '2') {
      return true;
    }
    
    // Jack can be played on anything
    if (card.rank === 'J') {
      return true;
    }
    
    // Jokers can be played on same color or other jokers
    if (card.rank === 'Joker') {
      return current.rank === 'Joker' || card.color === current.color;
    }
    
    // Regular matching rules
    return card.suit === current.suit || card.rank === current.rank;
  }
}
```

## Client-Side State Management

### Flutter State Architecture
```dart
// Game State Model
@freezed
class GameState with _$GameState {
  const factory GameState({
    required String gameId,
    required String sessionId,
    required int gameNumber,
    required GameStatus status,
    required List<GamePlayer> players,
    required String currentPlayerId,
    required int turnDirection,
    required List<String> playOrder,
    required GameCard currentCard,
    required int drawPileSize,
    required int discardPileSize,
    required int attackStack,
    GameSuit? chosenSuit,
    required bool skipNextPlayer,
    required List<GameCard> playerHand, // Current player's hand
    DateTime? startedAt,
    DateTime? completedAt,
    String? winnerId,
    String? loserId,
  }) = _GameState;
  
  // Computed properties
  bool get isMyTurn => currentPlayerId == currentPlayer?.id;
  GamePlayer? get currentPlayer => players.firstWhereOrNull((p) => p.id == currentPlayerId);
  bool get canPlayCard => isMyTurn && status == GameStatus.active;
  bool get isUnderAttack => attackStack > 0;
}

// State Notifier
class GameStateNotifier extends StateNotifier<AsyncValue<GameState?>> {
  final WebSocketService _webSocketService;
  final GameRepository _gameRepository;
  
  GameStateNotifier(this._webSocketService, this._gameRepository) 
    : super(const AsyncValue.loading()) {
    _webSocketService.events.listen(_handleWebSocketEvent);
  }
  
  void _handleWebSocketEvent(WebSocketEvent event) {
    event.when(
      gameStarted: (gameData) => _updateGameState(gameData.gameState),
      gameStateUpdate: (gameData) => _updateGameState(gameData.gameState),
      cardPlayed: (data) => _updateAfterCardPlayed(data),
      playerEliminated: (data) => _handlePlayerElimination(data),
      gameFinished: (data) => _handleGameFinished(data),
      invalidAction: (error) => _handleInvalidAction(error),
    );
  }
  
  // Action methods
  Future<void> playCard(GameCard card, {GameSuit? chosenSuit}) async {
    if (!_canPlayCard(card)) return;
    
    // Optimistic update
    final currentState = state.value!;
    final optimisticState = _createOptimisticState(currentState, card);
    state = AsyncValue.data(optimisticState);
    
    try {
      await _webSocketService.sendEvent(PlayCardEvent(
        card: card,
        chosenSuit: chosenSuit,
      ));
    } catch (error) {
      // Revert optimistic update
      state = AsyncValue.data(currentState);
      rethrow;
    }
  }
  
  Future<void> drawCard() async {
    await _webSocketService.sendEvent(const DrawCardEvent());
  }
  
  // Private helper methods
  GameState _createOptimisticState(GameState current, GameCard card) {
    // Create optimistic state for UI responsiveness
    final newHand = current.playerHand.where((c) => c.id != card.id).toList();
    
    return current.copyWith(
      playerHand: newHand,
      currentCard: card,
      discardPileSize: current.discardPileSize + 1,
    );
  }
  
  bool _canPlayCard(GameCard card) {
    final state = this.state.value;
    if (state == null || !state.canPlayCard) return false;
    
    return GameRules.isValidPlay(state.currentCard, card, state.attackStack > 0);
  }
}
```

### Game Rules Validation
```dart
class GameRules {
  static bool isValidPlay(GameCard currentCard, GameCard playedCard, bool isUnderAttack) {
    // During attack, only counter cards allowed
    if (isUnderAttack) {
      return playedCard.rank == CardRank.seven || playedCard.rank == CardRank.joker;
    }
    
    // Transparent 2 can always be played (except during attack)
    if (playedCard.rank == CardRank.two) {
      return true;
    }
    
    // Jack can always be played (except during attack)
    if (playedCard.rank == CardRank.jack) {
      return true;
    }
    
    // Jokers match same color or other jokers
    if (playedCard.rank == CardRank.joker) {
      return currentCard.rank == CardRank.joker || 
             playedCard.color == currentCard.color;
    }
    
    // Standard matching: same suit or rank
    return playedCard.suit == currentCard.suit || 
           playedCard.rank == currentCard.rank;
  }
  
  static List<GameCard> getPlayableCards(
    List<GameCard> hand, 
    GameCard currentCard, 
    bool isUnderAttack
  ) {
    return hand.where((card) => isValidPlay(currentCard, card, isUnderAttack)).toList();
  }
  
  static CardEffect getCardEffect(CardRank rank) {
    switch (rank) {
      case CardRank.ace:
        return CardEffect.skip;
      case CardRank.seven:
        return CardEffect.drawTwo;
      case CardRank.jack:
        return CardEffect.chooseSuit;
      case CardRank.joker:
        return CardEffect.drawFour;
      case CardRank.two:
        return CardEffect.transparent;
      default:
        return CardEffect.none;
    }
  }
}
```

## Synchronization Strategy

### Event-Driven Updates
1. **Server Authority**: Server maintains canonical game state
2. **Event Broadcasting**: All state changes broadcast as events
3. **Client Reconciliation**: Clients update local state from events
4. **Optimistic Updates**: Immediate UI updates with server confirmation
5. **Conflict Resolution**: Server state always takes precedence

### State Consistency
```typescript
class StateManager {
  private gameStates = new Map<string, GameState>();
  
  updateGameState(gameId: string, newState: GameState): void {
    const currentState = this.gameStates.get(gameId);
    
    if (currentState && currentState.version >= newState.version) {
      // Ignore outdated updates
      return;
    }
    
    this.gameStates.set(gameId, newState);
    this.broadcastStateUpdate(gameId, newState);
  }
  
  private broadcastStateUpdate(gameId: string, gameState: GameState): void {
    const event: GameStateUpdateEvent = {
      type: 'game_state_update',
      data: {
        gameState: this.sanitizeStateForClients(gameState),
        timestamp: new Date().toISOString(),
      }
    };
    
    // Send personalized state to each player
    gameState.players.forEach(player => {
      const personalizedEvent = {
        ...event,
        data: {
          ...event.data,
          playerHand: player.hand, // Only to this player
        }
      };
      
      this.sendToPlayer(player.sessionPlayerId, personalizedEvent);
    });
  }
  
  private sanitizeStateForClients(gameState: GameState): PublicGameState {
    return {
      ...gameState,
      drawPile: [], // Don't send actual cards
      players: gameState.players.map(p => ({
        ...p,
        hand: [], // Don't send other players' cards
        handSize: p.hand.length,
      }))
    };
  }
}
```

### Error Recovery
```dart
class GameErrorRecovery {
  static Future<void> handleStateDesync(GameStateNotifier notifier) async {
    // Request full state resync from server
    await notifier._webSocketService.sendEvent(const RequestStateSyncEvent());
  }
  
  static Future<void> handleConnectionRecovery(
    GameStateNotifier notifier,
    String gameId,
  ) async {
    try {
      // Get latest state from API as fallback
      final gameState = await notifier._gameRepository.getGameState(gameId);
      notifier._updateGameState(gameState);
    } catch (error) {
      // Fall back to cached state or show error
      notifier.state = AsyncValue.error(error, StackTrace.current);
    }
  }
}
```

## Performance Optimizations

### State Updates
- **Immutable State**: All state objects are immutable for predictable updates
- **Selective Updates**: Only changed fields trigger UI rebuilds
- **Batch Updates**: Multiple rapid updates batched into single UI update
- **Memory Management**: Old game states garbage collected after completion

### Client-Side Caching
```dart
class GameStateCache {
  static const int maxCachedGames = 10;
  final Map<String, GameState> _cache = {};
  
  void cacheGameState(String gameId, GameState state) {
    if (_cache.length >= maxCachedGames) {
      final oldestKey = _cache.keys.first;
      _cache.remove(oldestKey);
    }
    _cache[gameId] = state;
  }
  
  GameState? getCachedState(String gameId) => _cache[gameId];
  
  void clearCache() => _cache.clear();
}
```

### Database Optimization
- **Indexed Queries**: Proper indexes on frequently queried fields
- **Connection Pooling**: Efficient database connection management
- **Batch Operations**: Group related database operations
- **Read Replicas**: Use read replicas for non-critical queries

## Testing Strategy

### Unit Tests
- Game rules validation
- State transition logic  
- Card effect processing
- Turn management

### Integration Tests
- WebSocket event flow
- Database state persistence
- Client-server synchronization
- Error recovery mechanisms

### Load Tests
- Concurrent game sessions
- High-frequency player actions
- Network latency simulation
- Memory usage under load