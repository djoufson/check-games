import 'dart:async';
import 'package:flutter/material.dart';
import '../services/signalr_service.dart';
import '../api/models/signalr_events.dart';

class SignalRProvider with ChangeNotifier {
  final SignalRService _signalRService = SignalRService();

  SignalRConnectionStatus _connectionStatus =
      SignalRConnectionStatus.disconnected;
  SignalREvent? _lastGameEvent;
  StreamSubscription<SignalRConnectionStatus>? _statusSubscription;
  StreamSubscription<SignalREvent>? _eventSubscription;
  String? _currentSessionId;

  SignalRProvider() {
    _initializeListeners();
  }

  // Getters
  SignalRConnectionStatus get connectionStatus => _connectionStatus;
  SignalREvent? get lastGameEvent => _lastGameEvent;
  String? get currentSessionId => _currentSessionId;
  bool get isConnected =>
      _connectionStatus == SignalRConnectionStatus.connected;
  bool get isConnecting =>
      _connectionStatus == SignalRConnectionStatus.connecting;
  bool get isReconnecting =>
      _connectionStatus == SignalRConnectionStatus.reconnecting;
  bool get isDisconnected =>
      _connectionStatus == SignalRConnectionStatus.disconnected;
  bool get hasFailed => _connectionStatus == SignalRConnectionStatus.failed;

  /// Get connection status as a user-friendly string
  String get connectionStatusText {
    switch (_connectionStatus) {
      case SignalRConnectionStatus.connected:
        return 'Connected';
      case SignalRConnectionStatus.connecting:
        return 'Connecting...';
      case SignalRConnectionStatus.reconnecting:
        return 'Reconnecting...';
      case SignalRConnectionStatus.disconnected:
        return 'Disconnected';
      case SignalRConnectionStatus.failed:
        return 'Connection Failed';
    }
  }

  /// Get connection status color for UI indicators
  Color get connectionStatusColor {
    switch (_connectionStatus) {
      case SignalRConnectionStatus.connected:
        return Colors.green;
      case SignalRConnectionStatus.connecting:
      case SignalRConnectionStatus.reconnecting:
        return Colors.orange;
      case SignalRConnectionStatus.disconnected:
        return Colors.grey;
      case SignalRConnectionStatus.failed:
        return Colors.red;
    }
  }

  /// Initialize event listeners
  void _initializeListeners() {
    _statusSubscription = _signalRService.statusStream.listen((status) {
      _connectionStatus = status;
      notifyListeners();
      debugPrint('SignalR Provider: Status changed to $status');
    });

    _eventSubscription = _signalRService.gameEventStream.listen((event) {
      _lastGameEvent = event;
      notifyListeners();
      debugPrint('SignalR Provider: Game event received: ${event.runtimeType}');
    });
  }

  /// Initialize SignalR connection
  Future<void> initialize({String? accessToken}) async {
    try {
      await _signalRService.initialize(accessToken: accessToken);
    } catch (e) {
      debugPrint('SignalR Provider: Error initializing: $e');
    }
  }

  /// Update access token
  Future<void> updateAccessToken(String? token) async {
    try {
      await _signalRService.updateAccessToken(token);
    } catch (e) {
      debugPrint('SignalR Provider: Error updating token: $e');
    }
  }

  /// Join a game session
  Future<void> joinGameSession(String sessionId, {String? playerName}) async {
    try {
      await _signalRService.joinGameSession(sessionId, playerName: playerName);
      _currentSessionId = sessionId;
      notifyListeners();
    } catch (e) {
      debugPrint('SignalR Provider: Error joining session: $e');
    }
  }

  /// Leave the current game session
  Future<void> leaveCurrentSession() async {
    if (_currentSessionId == null) return;

    try {
      await _signalRService.leaveGameSession(_currentSessionId!);
      _currentSessionId = null;
      notifyListeners();
    } catch (e) {
      debugPrint('SignalR Provider: Error leaving session: $e');
    }
  }

  /// Play a card
  Future<void> playCard(Map<String, dynamic> cardData) async {
    if (_currentSessionId == null) {
      debugPrint('SignalR Provider: Cannot play card - no current session');
      return;
    }

    try {
      await _signalRService.playCard(_currentSessionId!, cardData);
    } catch (e) {
      debugPrint('SignalR Provider: Error playing card: $e');
    }
  }

  /// Draw a card
  Future<void> drawCard() async {
    if (_currentSessionId == null) {
      debugPrint('SignalR Provider: Cannot draw card - no current session');
      return;
    }

    try {
      await _signalRService.drawCard(_currentSessionId!);
    } catch (e) {
      debugPrint('SignalR Provider: Error drawing card: $e');
    }
  }

  /// Send a game message
  Future<void> sendGameMessage(String message) async {
    if (_currentSessionId == null) {
      debugPrint('SignalR Provider: Cannot send message - no current session');
      return;
    }

    try {
      await _signalRService.sendGameMessage(_currentSessionId!, message);
    } catch (e) {
      debugPrint('SignalR Provider: Error sending message: $e');
    }
  }

  /// Change suit
  Future<void> changeSuit(String newSuit) async {
    if (_currentSessionId == null) {
      debugPrint('SignalR Provider: Cannot change suit - no current session');
      return;
    }

    try {
      await _signalRService.changeSuit(_currentSessionId!, newSuit);
    } catch (e) {
      debugPrint('SignalR Provider: Error changing suit: $e');
    }
  }

  /// Request current game state
  Future<void> requestGameState() async {
    if (_currentSessionId == null) {
      debugPrint(
        'SignalR Provider: Cannot request game state - no current session',
      );
      return;
    }

    try {
      await _signalRService.requestGameState(_currentSessionId!);
    } catch (e) {
      debugPrint('SignalR Provider: Error requesting game state: $e');
    }
  }

  /// Manually reconnect
  Future<void> reconnect() async {
    try {
      await _signalRService.reconnect();
    } catch (e) {
      debugPrint('SignalR Provider: Error reconnecting: $e');
    }
  }

  /// Clear last game event
  void clearLastEvent() {
    _lastGameEvent = null;
    notifyListeners();
  }

  /// Listen to specific game event types
  Stream<T> listenToEventType<T extends SignalREvent>() {
    return _signalRService.gameEventStream
        .where((event) => event is T)
        .cast<T>();
  }

  /// Get events for the current session only
  Stream<SignalREvent> get currentSessionEvents {
    return _signalRService.gameEventStream.where((event) {
      // Check if event has a sessionId property and matches current session
      if (_currentSessionId == null) return false;
      
      switch (event) {
        case PlayerJoinedEvent(sessionId: var sessionId):
        case PlayerLeftEvent(sessionId: var sessionId):
        case GameStateUpdatedEvent(sessionId: var sessionId):
        case GameStartedEvent(sessionId: var sessionId):
        case GameEndedEvent(sessionId: var sessionId):
        case TurnChangedEvent(sessionId: var sessionId):
        case CardPlayedEvent(sessionId: var sessionId):
        case CardDrawnEvent(sessionId: var sessionId):
        case SuitChangedEvent(sessionId: var sessionId):
        case GameMessageEvent(sessionId: var sessionId):
          return sessionId == _currentSessionId;
        default:
          return false;
      }
    });
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _eventSubscription?.cancel();
    _signalRService.dispose();
    super.dispose();
  }
}
