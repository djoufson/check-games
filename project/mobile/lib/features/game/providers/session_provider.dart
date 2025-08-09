import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/api/models/session_models.dart';
import '../../../core/api/models/signalr_events.dart';
import '../../../core/api/services/session_service.dart';
import '../../../core/services/signalr_service.dart';

class SessionProvider with ChangeNotifier {
  final SessionService _sessionService;
  final SignalRService _signalRService = SignalRService();

  GameSession? _currentSession;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<SignalREvent>? _signalRSubscription;
  StreamSubscription<SignalRErrorEvent>? _signalRErrorSubscription;

  SessionProvider({SessionService? sessionService})
    : _sessionService = sessionService ?? SessionService();

  // Getters
  GameSession? get currentSession => _currentSession;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasSession => _currentSession != null;

  /// Update the access token for API calls
  void updateAccessToken(String? token) {
    _sessionService.updateToken(token);
  }

  /// Create a new game session
  Future<bool> createSession({
    String? description,
    required int maxPlayersLimit,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final request = CreateSessionRequest(
        description: description,
        maxPlayersLimit: maxPlayersLimit,
      );

      final response = await _sessionService.createSession(request);

      if (response.success && response.data != null) {
        _currentSession = response.data!.session;
        await _joinSignalRSession(_currentSession!.id);
        _setupSignalRListeners();
        _setLoading(false);
        return true;
      } else {
        _setError(response.error ?? 'Failed to create session');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Load an existing session by ID
  Future<bool> loadSession(String sessionId) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _sessionService.getSession(sessionId);

      if (response.success && response.data != null) {
        _currentSession = response.data!;
        await _joinSignalRSession(_currentSession!.id);
        _setupSignalRListeners();
        _setLoading(false);
        return true;
      } else {
        _setError(response.error ?? 'Failed to load session');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Join a session using session code
  Future<bool> joinSession(String sessionCode, String? playerName) async {
    _setLoading(true);
    _clearError();

    try {
      final request = JoinSessionRequest(playerName: playerName);
      final response = await _sessionService.joinSession(sessionCode, request);

      if (response.success && response.data != null) {
        _currentSession = response.data!.session;
        // Use the assigned player name from the server response
        await _joinSignalRSession(_currentSession!.id, playerName: response.data!.assignedPlayerName);
        _setupSignalRListeners();
        _setLoading(false);
        return true;
      } else {
        _setError(response.error ?? 'Failed to join session');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// Leave the current session
  Future<bool> leaveSession() async {
    if (_currentSession == null) return false;

    try {
      // Leave SignalR session first
      await _signalRService.leaveGameSession(_currentSession!.id);

      // Call API to leave session
      final response = await _sessionService.leaveSession(_currentSession!.id);

      if (response.success) {
        _cleanup();
        return true;
      } else {
        _setError(response.error ?? 'Failed to leave session');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      return false;
    }
  }

  /// Start the current session (host only)
  Future<bool> startSession() async {
    if (_currentSession == null) return false;

    try {
      final response = await _sessionService.startSession(_currentSession!.id);

      if (response.success && response.data != null) {
        _currentSession = response.data!;
        notifyListeners();
        return true;
      } else {
        _setError(response.error ?? 'Failed to start session');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred: ${e.toString()}');
      return false;
    }
  }

  /// Join SignalR session for real-time updates
  Future<void> _joinSignalRSession(String sessionId, {String? playerName}) async {
    debugPrint('SessionProvider: Attempting to join SignalR session: $sessionId (SignalR connected: ${_signalRService.isConnected})');
    
    try {
      // Ensure SignalR is connected before attempting to join
      if (!_signalRService.isConnected) {
        debugPrint('SessionProvider: SignalR not connected, cannot join session without connection');
        return;
      }
      
      await _signalRService.joinGameSession(sessionId, playerName: playerName);
      debugPrint('SessionProvider: Successfully joined SignalR session: $sessionId${playerName != null ? ' as $playerName' : ''}');
    } catch (e) {
      debugPrint('SessionProvider: Failed to join SignalR session: $e');
    }
  }

  /// Setup SignalR event listeners with type-safe event handling
  void _setupSignalRListeners() {
    _signalRSubscription?.cancel();
    _signalRErrorSubscription?.cancel();

    _signalRSubscription = _signalRService.gameEventStream.listen(
      _handleSignalREvent,
      onError: (error) {
        debugPrint('SessionProvider: SignalR event stream error: $error');
        _setError('Real-time connection error occurred');
      },
    );

    _signalRErrorSubscription = _signalRService.errorEventStream.listen(
      _handleSignalRErrorEvent,
      onError: (error) {
        debugPrint('SessionProvider: SignalR error stream error: $error');
      },
    );
  }

  /// Handle type-safe SignalR events
  void _handleSignalREvent(SignalREvent event) {
    if (_currentSession == null) {
      debugPrint('SessionProvider: Ignoring SignalR event ${event.runtimeType} - no current session');
      return;
    }

    debugPrint('SessionProvider: Processing SignalR event: ${event.runtimeType} for session: ${_currentSession!.id}');

    switch (event) {
      case PlayerJoinedEvent():
        _handlePlayerJoined(event);
        break;
      case PlayerLeftEvent():
        _handlePlayerLeft(event);
        break;
      case GameStateUpdatedEvent():
        _handleGameStateUpdated(event);
        break;
      case GameStartedEvent():
        _handleGameStarted(event);
        break;
      case GameEndedEvent():
        _handleGameEnded(event);
        break;
      case TurnChangedEvent():
        _handleTurnChanged(event);
        break;
      case CardPlayedEvent():
        _handleCardPlayed(event);
        break;
      case CardDrawnEvent():
        _handleCardDrawn(event);
        break;
      case SuitChangedEvent():
        _handleSuitChanged(event);
        break;
      case GameMessageEvent():
        _handleGameMessage(event);
        break;
      default:
        debugPrint('SessionProvider: Unhandled SignalR event: ${event.runtimeType}');
    }
  }

  /// Handle SignalR error events
  void _handleSignalRErrorEvent(SignalRErrorEvent errorEvent) {
    debugPrint('SessionProvider: SignalR error: ${errorEvent.message}');
    _setError(errorEvent.message);
  }

  void _handlePlayerJoined(PlayerJoinedEvent event) {
    if (_currentSession == null || event.sessionId != _currentSession!.id) return;

    try {
      // Check if player already exists
      if (!_currentSession!.players.contains(event.userName)) {
        // Add new player to the session
        final newPlayerCount = _currentSession!.currentPlayerCount + 1;
        _currentSession = _currentSession!.copyWith(
          players: [..._currentSession!.players, event.userName],
          currentPlayerCount: newPlayerCount,
        );
        notifyListeners();
        debugPrint('SessionProvider: Player joined: ${event.userName} (Session: ${event.sessionId}, Total players: $newPlayerCount)');
      } else {
        debugPrint('SessionProvider: Player ${event.userName} already in session, skipping');
      }
    } catch (e) {
      debugPrint('SessionProvider: Error handling PlayerJoined: $e');
    }
  }

  void _handlePlayerLeft(PlayerLeftEvent event) {
    if (_currentSession == null || event.sessionId != _currentSession!.id) return;

    try {
      // Remove player from the session
      final updatedPlayers = _currentSession!.players
          .where((player) => player != event.userName)
          .toList();
      
      _currentSession = _currentSession!.copyWith(
        players: updatedPlayers,
        currentPlayerCount: updatedPlayers.length,
      );
      notifyListeners();
      debugPrint('SessionProvider: Player left: ${event.userName} (Session: ${event.sessionId}, Total players: ${updatedPlayers.length})');
    } catch (e) {
      debugPrint('SessionProvider: Error handling PlayerLeft: $e');
    }
  }

  void _handleGameStateUpdated(GameStateUpdatedEvent event) {
    if (_currentSession == null || event.sessionId != _currentSession!.id) return;

    try {
      // Update the current session with new game state data
      if (event.gameState.containsKey('session')) {
        final sessionData = event.gameState['session'] as Map<String, dynamic>;
        final updatedSession = GameSession.fromJson(sessionData);
        _currentSession = updatedSession;
        notifyListeners();
        debugPrint('SessionProvider: Game state updated for session: ${event.sessionId}');
      }
    } catch (e) {
      debugPrint('SessionProvider: Error handling GameStateUpdated: $e');
    }
  }

  void _handleGameStarted(GameStartedEvent event) {
    if (_currentSession == null || event.sessionId != _currentSession!.id) return;

    try {
      _currentSession = _currentSession!.copyWith(
        status: GameSessionStatus.inProgress,
        startedAt: event.timestamp,
      );
      notifyListeners();
      debugPrint('SessionProvider: Game started for session: ${event.sessionId}');
    } catch (e) {
      debugPrint('SessionProvider: Error handling GameStarted: $e');
    }
  }

  void _handleGameEnded(GameEndedEvent event) {
    if (_currentSession == null || event.sessionId != _currentSession!.id) return;

    try {
      _currentSession = _currentSession!.copyWith(
        status: GameSessionStatus.completed,
        endedAt: event.timestamp,
      );
      notifyListeners();
      debugPrint('SessionProvider: Game ended for session: ${event.sessionId}');
    } catch (e) {
      debugPrint('SessionProvider: Error handling GameEnded: $e');
    }
  }

  void _handleTurnChanged(TurnChangedEvent event) {
    if (_currentSession == null || event.sessionId != _currentSession!.id) return;

    try {
      // For now, just log the turn change - we can expand this later
      debugPrint('SessionProvider: Turn changed from ${event.currentPlayerId} to ${event.nextPlayerId}');
    } catch (e) {
      debugPrint('SessionProvider: Error handling TurnChanged: $e');
    }
  }

  void _handleCardPlayed(CardPlayedEvent event) {
    if (_currentSession == null || event.sessionId != _currentSession!.id) return;

    try {
      // For now, just log the card play - we can expand this later
      debugPrint('SessionProvider: Card played by ${event.userName} in session: ${event.sessionId}');
    } catch (e) {
      debugPrint('SessionProvider: Error handling CardPlayed: $e');
    }
  }

  void _handleCardDrawn(CardDrawnEvent event) {
    if (_currentSession == null || event.sessionId != _currentSession!.id) return;

    try {
      // For now, just log the card draw - we can expand this later
      debugPrint('SessionProvider: Card drawn by ${event.userName} in session: ${event.sessionId}');
    } catch (e) {
      debugPrint('SessionProvider: Error handling CardDrawn: $e');
    }
  }

  void _handleSuitChanged(SuitChangedEvent event) {
    if (_currentSession == null || event.sessionId != _currentSession!.id) return;

    try {
      // For now, just log the suit change - we can expand this later
      debugPrint('SessionProvider: Suit changed to ${event.newSuit} by ${event.userName}');
    } catch (e) {
      debugPrint('SessionProvider: Error handling SuitChanged: $e');
    }
  }

  void _handleGameMessage(GameMessageEvent event) {
    if (_currentSession == null || event.sessionId != _currentSession!.id) return;

    try {
      // For now, just log the message - we can expand this later with a message list
      debugPrint('SessionProvider: Game message from ${event.userName}: ${event.message}');
    } catch (e) {
      debugPrint('SessionProvider: Error handling GameMessage: $e');
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  void _cleanup() {
    _signalRSubscription?.cancel();
    _signalRErrorSubscription?.cancel();
    _signalRSubscription = null;
    _signalRErrorSubscription = null;
    _currentSession = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _signalRSubscription?.cancel();
    _signalRErrorSubscription?.cancel();
    _sessionService.dispose();
    super.dispose();
  }
}
