# Check-Game Frontend Architecture

## Overview
The frontend is a Flutter application providing cross-platform support for iOS, Android, Web, and Desktop. It implements a real-time, event-driven UI that responds to game state changes from the WebSocket server.

## Technology Stack

### Core Framework
- **Flutter**: 3.16+ (Dart 3.2+)
- **Target Platforms**: iOS, Android, Web, Desktop (Windows, macOS, Linux)
- **UI Framework**: Material Design 3

### State Management
- **Primary**: Riverpod 2.4+
- **Pattern**: Provider pattern with StateNotifier
- **Local Storage**: SharedPreferences + Hive for complex data
- **Secure Storage**: flutter_secure_storage for tokens

### Real-time Communication
- **WebSocket**: web_socket_channel 2.4+
- **HTTP Client**: dio 5.3+ with interceptors
- **JSON Serialization**: json_annotation + json_serializable

### Additional Packages
- **Routing**: go_router 12.0+
- **Forms**: flutter_form_builder 9.0+
- **Animations**: flutter_animate 4.0+
- **Theming**: dynamic_color (Material You)
- **Platform Integration**: flutter_native_splash, flutter_launcher_icons

## Project Structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart                    # Root app widget
│   ├── router.dart                 # App routing configuration
│   └── theme.dart                  # Material Design 3 theme
├── core/
│   ├── constants/
│   │   ├── api_constants.dart      # API URLs and endpoints
│   │   ├── app_constants.dart      # App-wide constants
│   │   └── storage_keys.dart       # Local storage keys
│   ├── errors/
│   │   ├── exceptions.dart         # Custom exceptions
│   │   └── failures.dart          # Error handling
│   ├── network/
│   │   ├── api_client.dart         # HTTP client setup
│   │   ├── websocket_client.dart   # WebSocket connection
│   │   └── network_info.dart       # Connectivity checking
│   ├── storage/
│   │   ├── local_storage.dart      # SharedPreferences wrapper
│   │   └── secure_storage.dart     # Secure token storage
│   └── utils/
│       ├── validators.dart         # Form validation
│       ├── extensions.dart         # Dart extensions
│       └── logger.dart            # Logging utility
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/             # Auth data models
│   │   │   ├── repositories/       # Auth repository implementation
│   │   │   └── datasources/        # API/local data sources
│   │   ├── domain/
│   │   │   ├── entities/           # Auth domain models
│   │   │   ├── repositories/       # Repository interfaces
│   │   │   └── usecases/          # Auth use cases
│   │   └── presentation/
│   │       ├── providers/          # Riverpod providers
│   │       ├── pages/             # Auth screens
│   │       └── widgets/           # Reusable auth widgets
│   ├── session/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── game/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── profile/
│       ├── data/
│       ├── domain/
│       └── presentation/
├── shared/
│   ├── widgets/
│   │   ├── common/                 # Reusable UI components
│   │   ├── cards/                 # Card-related widgets
│   │   └── animations/            # Custom animations
│   ├── models/                    # Shared data models
│   └── providers/                 # Global providers
└── gen/                          # Generated files
    └── assets.gen.dart           # Asset generation
```

## Architecture Patterns

### Clean Architecture
```
Presentation Layer (UI) ←→ Domain Layer (Business Logic) ←→ Data Layer (Repository Pattern)
```

### Layer Responsibilities

#### Presentation Layer
- **Providers**: State management with Riverpod
- **Pages**: Full-screen UI components
- **Widgets**: Reusable UI components
- **State**: UI state and user interactions

#### Domain Layer
- **Entities**: Core business objects
- **Use Cases**: Business logic operations
- **Repositories**: Abstract data access interfaces
- **Value Objects**: Domain-specific data types

#### Data Layer
- **Models**: Data transfer objects
- **Repositories**: Concrete repository implementations
- **Data Sources**: API clients, local storage
- **Mappers**: Convert between models and entities

## State Management Architecture

### Riverpod Provider Structure
```dart
// Example provider hierarchy
final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepositoryImpl());

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.watch(authRepositoryProvider))
);

final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState>(
  (ref) => GameStateNotifier(ref.watch(webSocketProvider))
);

final sessionListProvider = FutureProvider<List<Session>>((ref) {
  final repository = ref.watch(sessionRepositoryProvider);
  return repository.getSessions();
});
```

### State Classes
```dart
// Auth State
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}

// Game State
@freezed
class GameState with _$GameState {
  const factory GameState({
    required String gameId,
    required List<Player> players,
    required GameCard currentCard,
    required int drawPileSize,
    required String currentPlayerId,
    required GameStatus status,
    @Default([]) List<GameCard> playerHand,
    @Default(0) int attackStack,
  }) = _GameState;
}
```

## WebSocket Integration

### Connection Management
```dart
class WebSocketClient {
  late WebSocketChannel _channel;
  final StreamController<GameEvent> _eventController = StreamController.broadcast();
  
  Stream<GameEvent> get events => _eventController.stream;
  
  Future<void> connect(String sessionToken) async {
    final uri = Uri.parse('$wsBaseUrl/game?token=$sessionToken');
    _channel = WebSocketChannel.connect(uri);
    
    _channel.stream.listen(
      _handleMessage,
      onError: _handleError,
      onDone: _handleDisconnection,
    );
  }
  
  void sendEvent(GameEvent event) {
    _channel.sink.add(jsonEncode(event.toJson()));
  }
}
```

### Event Handling
```dart
class GameStateNotifier extends StateNotifier<GameState> {
  final WebSocketClient _webSocketClient;
  
  GameStateNotifier(this._webSocketClient) : super(GameState.initial()) {
    _webSocketClient.events.listen(_handleGameEvent);
  }
  
  void _handleGameEvent(GameEvent event) {
    event.when(
      gameStateUpdate: (gameState) => state = gameState,
      playerJoined: (player) => _addPlayer(player),
      cardPlayed: (card, playerId) => _updateAfterCardPlayed(card, playerId),
      turnSkipped: (playerId) => _skipPlayerTurn(playerId),
      gameFinished: (winnerId, loserId) => _finishGame(winnerId, loserId),
    );
  }
}
```

## UI Components Architecture

### Screen Structure
```dart
class GameScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    
    return Scaffold(
      body: gameState.when(
        loading: () => const LoadingWidget(),
        error: (error) => ErrorWidget(error),
        data: (game) => GameView(game: game),
      ),
    );
  }
}
```

### Card Animation System
```dart
class AnimatedCard extends StatefulWidget {
  final GameCard card;
  final VoidCallback? onTap;
  final bool isPlayable;
  
  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        ScaleEffect(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: 200.ms,
        ),
        if (isPlayable)
          ShimmerEffect(
            color: Theme.of(context).primaryColor,
            duration: 1000.ms,
          ),
      ],
      child: CardWidget(card: card, onTap: onTap),
    );
  }
}
```

## Responsive Design

### Screen Size Adaptation
```dart
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 800) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}
```

### Platform-Specific Features
```dart
class PlatformService {
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
  static bool get isDesktop => Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  static bool get isWeb => kIsWeb;
  
  // Platform-specific implementations
  static void showNotification(String message) {
    if (isMobile) {
      // Use local notifications
    } else if (isWeb) {
      // Use browser notifications
    }
  }
}
```

## Error Handling & Loading States

### Global Error Handler
```dart
class GlobalErrorHandler {
  static void handleError(Object error, StackTrace stackTrace) {
    if (error is ApiException) {
      _showApiError(error);
    } else if (error is NetworkException) {
      _showNetworkError();
    } else {
      _showGenericError();
    }
    
    // Log to analytics/crashlytics
    Logger.error('Global error', error, stackTrace);
  }
}
```

### Loading State Management
```dart
final loadingProvider = StateProvider<bool>((ref) => false);

class LoadingOverlay extends ConsumerWidget {
  final Widget child;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(loadingProvider);
    
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
```

## Testing Architecture

### Widget Tests
```dart
void main() {
  group('GameScreen Tests', () {
    testWidgets('displays game state correctly', (tester) async {
      final mockGameState = GameState.initial();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameStateProvider.overrideWith((ref) => mockGameState),
          ],
          child: MaterialApp(home: GameScreen()),
        ),
      );
      
      expect(find.byType(GameView), findsOneWidget);
    });
  });
}
```

### Integration Tests
```dart
void main() {
  group('Game Flow Integration Tests', () {
    testWidgets('complete game flow', (tester) async {
      // Test full game flow from login to game completion
    });
  });
}
```

## Performance Optimization

### Image and Asset Management
- Use cached network images for user avatars
- Optimize card images with proper compression
- Implement lazy loading for large lists
- Use `RepaintBoundary` for complex widgets

### Memory Management
- Dispose controllers and listeners properly
- Use `AutoDispose` providers where appropriate
- Implement proper WebSocket cleanup
- Monitor memory usage in debug mode

### Network Optimization
- Cache API responses where appropriate
- Implement retry logic for failed requests
- Use connection pooling for HTTP requests
- Minimize WebSocket message payload sizes

## Accessibility

### Screen Reader Support
- Semantic labels for all interactive elements
- Proper focus management
- Audio cues for important game events
- High contrast mode support

### Internationalization
- Multi-language support using Flutter's intl package
- RTL layout support
- Cultural-appropriate number and date formatting
- Dynamic font scaling

## Security Considerations

### Token Management
- Secure storage of JWT tokens
- Automatic token refresh
- Logout on token expiration
- Clear sensitive data on app termination

### Input Validation
- Client-side input validation
- XSS prevention in user-generated content
- Rate limiting for user actions
- Secure WebSocket connections (WSS)