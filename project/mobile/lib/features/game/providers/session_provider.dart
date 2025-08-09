import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/api/models/session_models.dart';
import '../../../core/api/services/session_service.dart';
import '../../../core/services/signalr_service.dart';

class SessionProvider with ChangeNotifier {
  final SessionService _sessionService;
  final SignalRService _signalRService = SignalRService();

  GameSession? _currentSession;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<Map<String, dynamic>>? _signalRSubscription;

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
    required String sessionName,
    int maxPlayers = 4,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final request = CreateSessionRequest(
        name: sessionName,
        maxPlayers: maxPlayers,
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
      final request = JoinSessionRequest(
        sessionCode: sessionCode,
        playerName: playerName,
      );

      final response = await _sessionService.joinSession(request);

      if (response.success && response.data != null) {
        _currentSession = response.data!.session;
        await _joinSignalRSession(_currentSession!.id);
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
  Future<void> _joinSignalRSession(String sessionId) async {
    try {
      await _signalRService.joinGameSession(sessionId);
      debugPrint('SessionProvider: Joined SignalR session: $sessionId');
    } catch (e) {
      debugPrint('SessionProvider: Failed to join SignalR session: $e');
    }
  }

  /// Setup SignalR event listeners
  void _setupSignalRListeners() {
    _signalRSubscription?.cancel();
    _signalRSubscription = _signalRService.gameEventStream.listen(
      _handleSignalREvent,
      onError: (error) {
        debugPrint('SessionProvider: SignalR error: $error');
      },
    );
  }

  /// Handle SignalR events
  void _handleSignalREvent(Map<String, dynamic> event) {
    if (_currentSession == null) return;

    final eventType = event['type'] as String?;
    final data = event['data'];

    debugPrint('SessionProvider: Received SignalR event: $eventType');

    switch (eventType) {
      case 'PlayerJoined':
        _handlePlayerJoined(data);
        break;
      case 'PlayerLeft':
        _handlePlayerLeft(data);
        break;
      case 'GameStateUpdated':
        _handleGameStateUpdated(data);
        break;
      case 'Error':
        _handleSignalRError(data);
        break;
      default:
        debugPrint('SessionProvider: Unhandled SignalR event: $eventType');
    }
  }

  void _handlePlayerJoined(dynamic data) {
    if (data == null || _currentSession == null) return;

    try {
      // final playerData = data as Map<String, dynamic>;
      // final newPlayer = SessionPlayer.fromJson(playerData);

      // // Check if player already exists
      // final existingPlayerIndex = _currentSession!.players
      //     .indexWhere((p) => p == newPlayer.name);

      // if (existingPlayerIndex == -1) {
      //   // Add new player
      //   _currentSession = _currentSession!.copyWith(
      //     players: [..._currentSession!.players, newPlayer.name],
      //   );
      //   notifyListeners();
      // }
    } catch (e) {
      debugPrint('SessionProvider: Error handling PlayerJoined: $e');
    }
  }

  void _handlePlayerLeft(dynamic data) {
    if (data == null || _currentSession == null) return;

    try {
      final playerData = data as Map<String, dynamic>;
      final playerId = playerData['playerId'] as String?;

      if (playerId != null) {
        // Remove player from list
        _currentSession = _currentSession!.copyWith(
          players: _currentSession!.players
              .where((p) => p != playerId)
              .toList(),
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('SessionProvider: Error handling PlayerLeft: $e');
    }
  }

  void _handleGameStateUpdated(dynamic data) {
    if (data == null || _currentSession == null) return;

    try {
      final sessionData = data as Map<String, dynamic>;
      final updatedSession = GameSession.fromJson(sessionData);
      _currentSession = updatedSession;
      notifyListeners();
    } catch (e) {
      debugPrint('SessionProvider: Error handling GameStateUpdated: $e');
    }
  }

  void _handleSignalRError(dynamic data) {
    if (data == null) return;

    try {
      final errorData = data as Map<String, dynamic>;
      final errorMessage =
          errorData['message'] as String? ?? 'SignalR error occurred';
      _setError(errorMessage);
    } catch (e) {
      debugPrint('SessionProvider: Error handling SignalR error: $e');
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
    _signalRSubscription = null;
    _currentSession = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _signalRSubscription?.cancel();
    _sessionService.dispose();
    super.dispose();
  }
}
