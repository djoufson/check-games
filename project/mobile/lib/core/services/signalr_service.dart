import 'dart:async';
import 'package:flutter/material.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../../config/api_config.dart';
import '../api/models/signalr_events.dart';

enum SignalRConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  failed,
}

class SignalRService {
  static final SignalRService _instance = SignalRService._internal();
  factory SignalRService() => _instance;
  SignalRService._internal();

  HubConnection? _connection;
  SignalRConnectionStatus _status = SignalRConnectionStatus.disconnected;
  String? _accessToken;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 5;
  static const Duration reconnectDelay = Duration(seconds: 5);

  // Stream controllers for connection status and events
  final StreamController<SignalRConnectionStatus> _statusController =
      StreamController<SignalRConnectionStatus>.broadcast();
  final StreamController<SignalREvent> _gameEventController =
      StreamController<SignalREvent>.broadcast();
  final StreamController<SignalRErrorEvent> _errorEventController =
      StreamController<SignalRErrorEvent>.broadcast();

  // Getters
  SignalRConnectionStatus get status => _status;
  Stream<SignalRConnectionStatus> get statusStream => _statusController.stream;
  Stream<SignalREvent> get gameEventStream => _gameEventController.stream;
  Stream<SignalRErrorEvent> get errorEventStream => _errorEventController.stream;
  bool get isConnected => _status == SignalRConnectionStatus.connected;
  HubConnection? get connection => _connection;

  /// Initialize SignalR connection
  Future<void> initialize({String? accessToken}) async {
    if (_connection != null &&
        _status != SignalRConnectionStatus.disconnected) {
      return; // Already initialized
    }

    _accessToken = accessToken;
    await _createConnection();
  }

  /// Create and configure the SignalR connection
  Future<void> _createConnection() async {
    try {
      const String hubUrl = ApiConfig.signalRHubUrl;

      final connectionBuilder = HubConnectionBuilder();

      // Configure URL with access token in headers if available
      if (_accessToken != null && _accessToken!.isNotEmpty) {
        _connection = connectionBuilder
            .withUrl(
              hubUrl,
              options: HttpConnectionOptions(
                accessTokenFactory: () => Future.value(_accessToken),
              ),
            )
            .withAutomaticReconnect()
            .build();
      } else {
        _connection = connectionBuilder
            .withUrl(hubUrl)
            .withAutomaticReconnect()
            .build();
      }

      _setupConnectionHandlers();
      _setupGameEventHandlers();

      await _connect();
    } catch (e) {
      debugPrint('SignalR: Error creating connection: $e');
      _updateStatus(SignalRConnectionStatus.failed);
    }
  }

  /// Set up connection event handlers
  void _setupConnectionHandlers() {
    if (_connection == null) return;

    // For now, we'll simulate connection status changes
    // The actual implementation would depend on the exact SignalR package API
    debugPrint('SignalR: Connection handlers set up');
  }

  /// Set up game event handlers with type-safe event parsing
  void _setupGameEventHandlers() {
    if (_connection == null) return;

    // Connection events
    _connection!.on('PlayerJoined', (message) {
      debugPrint('SignalR: PlayerJoined received: $message');
      try {
        if (message != null && message.isNotEmpty) {
          final eventData = message.first as Map<String, dynamic>;
          final event = PlayerJoinedEvent.fromJson(eventData);
          _gameEventController.add(event);
        }
      } catch (e) {
        debugPrint('SignalR: Error parsing PlayerJoined event: $e');
        _errorEventController.add(SignalRErrorEvent(message: 'Failed to parse PlayerJoined event'));
      }
    });

    _connection!.on('PlayerLeft', (message) {
      debugPrint('SignalR: PlayerLeft received: $message');
      try {
        if (message != null && message.isNotEmpty) {
          final eventData = message.first as Map<String, dynamic>;
          final event = PlayerLeftEvent.fromJson(eventData);
          _gameEventController.add(event);
        }
      } catch (e) {
        debugPrint('SignalR: Error parsing PlayerLeft event: $e');
        _errorEventController.add(SignalRErrorEvent(message: 'Failed to parse PlayerLeft event'));
      }
    });

    // Game action events
    _connection!.on('CardPlayed', (message) {
      debugPrint('SignalR: CardPlayed received: $message');
      try {
        if (message != null && message.isNotEmpty) {
          final eventData = message.first as Map<String, dynamic>;
          final event = CardPlayedEvent.fromJson(eventData);
          _gameEventController.add(event);
        }
      } catch (e) {
        debugPrint('SignalR: Error parsing CardPlayed event: $e');
        _errorEventController.add(SignalRErrorEvent(message: 'Failed to parse CardPlayed event'));
      }
    });

    _connection!.on('CardDrawn', (message) {
      debugPrint('SignalR: CardDrawn received: $message');
      try {
        if (message != null && message.isNotEmpty) {
          final eventData = message.first as Map<String, dynamic>;
          final event = CardDrawnEvent.fromJson(eventData);
          _gameEventController.add(event);
        }
      } catch (e) {
        debugPrint('SignalR: Error parsing CardDrawn event: $e');
        _errorEventController.add(SignalRErrorEvent(message: 'Failed to parse CardDrawn event'));
      }
    });

    _connection!.on('SuitChanged', (message) {
      debugPrint('SignalR: SuitChanged received: $message');
      try {
        if (message != null && message.isNotEmpty) {
          final eventData = message.first as Map<String, dynamic>;
          final event = SuitChangedEvent.fromJson(eventData);
          _gameEventController.add(event);
        }
      } catch (e) {
        debugPrint('SignalR: Error parsing SuitChanged event: $e');
        _errorEventController.add(SignalRErrorEvent(message: 'Failed to parse SuitChanged event'));
      }
    });

    _connection!.on('GameMessage', (message) {
      debugPrint('SignalR: GameMessage received: $message');
      try {
        if (message != null && message.isNotEmpty) {
          final eventData = message.first as Map<String, dynamic>;
          final event = GameMessageEvent.fromJson(eventData);
          _gameEventController.add(event);
        }
      } catch (e) {
        debugPrint('SignalR: Error parsing GameMessage event: $e');
        _errorEventController.add(SignalRErrorEvent(message: 'Failed to parse GameMessage event'));
      }
    });

    // Game state events
    _connection!.on('GameStateUpdated', (message) {
      debugPrint('SignalR: GameStateUpdated received: $message');
      try {
        if (message != null && message.isNotEmpty) {
          final eventData = message.first as Map<String, dynamic>;
          final event = GameStateUpdatedEvent.fromJson(eventData);
          _gameEventController.add(event);
        }
      } catch (e) {
        debugPrint('SignalR: Error parsing GameStateUpdated event: $e');
        _errorEventController.add(SignalRErrorEvent(message: 'Failed to parse GameStateUpdated event'));
      }
    });

    _connection!.on('GameStarted', (message) {
      debugPrint('SignalR: GameStarted received: $message');
      try {
        if (message != null && message.isNotEmpty) {
          final eventData = message.first as Map<String, dynamic>;
          final event = GameStartedEvent.fromJson(eventData);
          _gameEventController.add(event);
        }
      } catch (e) {
        debugPrint('SignalR: Error parsing GameStarted event: $e');
        _errorEventController.add(SignalRErrorEvent(message: 'Failed to parse GameStarted event'));
      }
    });

    _connection!.on('GameEnded', (message) {
      debugPrint('SignalR: GameEnded received: $message');
      try {
        if (message != null && message.isNotEmpty) {
          final eventData = message.first as Map<String, dynamic>;
          final event = GameEndedEvent.fromJson(eventData);
          _gameEventController.add(event);
        }
      } catch (e) {
        debugPrint('SignalR: Error parsing GameEnded event: $e');
        _errorEventController.add(SignalRErrorEvent(message: 'Failed to parse GameEnded event'));
      }
    });

    _connection!.on('TurnChanged', (message) {
      debugPrint('SignalR: TurnChanged received: $message');
      try {
        if (message != null && message.isNotEmpty) {
          final eventData = message.first as Map<String, dynamic>;
          final event = TurnChangedEvent.fromJson(eventData);
          _gameEventController.add(event);
        }
      } catch (e) {
        debugPrint('SignalR: Error parsing TurnChanged event: $e');
        _errorEventController.add(SignalRErrorEvent(message: 'Failed to parse TurnChanged event'));
      }
    });

    // Error handling
    _connection!.on('Error', (message) {
      debugPrint('SignalR: Error received: $message');
      try {
        String errorMessage = 'Unknown SignalR error';
        if (message != null && message.isNotEmpty) {
          // Handle both string and object error messages
          if (message.first is String) {
            errorMessage = message.first as String;
          } else if (message.first is Map<String, dynamic>) {
            final errorData = message.first as Map<String, dynamic>;
            errorMessage = errorData['message'] as String? ?? 'SignalR error occurred';
          }
        }
        _errorEventController.add(SignalRErrorEvent(message: errorMessage));
      } catch (e) {
        debugPrint('SignalR: Error parsing Error event: $e');
        _errorEventController.add(SignalRErrorEvent(message: 'Failed to parse error event'));
      }
    });
  }

  /// Connect to SignalR hub
  Future<void> _connect() async {
    if (_connection == null) return;

    try {
      _updateStatus(SignalRConnectionStatus.connecting);
      await _connection!.start();
      _updateStatus(SignalRConnectionStatus.connected);
      _reconnectAttempts = 0;
      debugPrint('SignalR: Connected successfully');
    } catch (e) {
      debugPrint('SignalR: Connection failed: $e');
      _updateStatus(SignalRConnectionStatus.failed);
      _scheduleReconnect();
    }
  }

  /// Schedule reconnection attempt
  void _scheduleReconnect() {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      debugPrint('SignalR: Max reconnect attempts reached');
      _updateStatus(SignalRConnectionStatus.failed);
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(reconnectDelay, () async {
      _reconnectAttempts++;
      debugPrint(
        'SignalR: Reconnect attempt $_reconnectAttempts/$maxReconnectAttempts',
      );
      await _connect();
    });
  }

  /// Update connection status and notify listeners
  void _updateStatus(SignalRConnectionStatus status) {
    if (_status != status) {
      _status = status;
      _statusController.add(status);
    }
  }

  /// Update authentication token and reconnect if needed
  Future<void> updateAccessToken(String? token) async {
    _accessToken = token;

    // If we're connected, we need to reconnect with the new token
    if (isConnected) {
      await disconnect();
      await initialize(accessToken: token);
    }
  }

  /// Join a game session
  Future<void> joinGameSession(String sessionId, {String? playerName}) async {
    if (!isConnected || _connection == null) {
      debugPrint('SignalR: Cannot join game session - not connected');
      return;
    }

    try {
      final args = <Object>[sessionId];
      if (playerName != null) {
        args.add(playerName);
      }
      await _connection!.invoke('JoinGameSession', args: args);
      debugPrint('SignalR: Joined game session: $sessionId');
    } catch (e) {
      debugPrint('SignalR: Error joining game session: $e');
    }
  }

  /// Leave a game session
  Future<void> leaveGameSession(String sessionId) async {
    if (!isConnected || _connection == null) {
      debugPrint('SignalR: Cannot leave game session - not connected');
      return;
    }

    try {
      await _connection!.invoke('LeaveGameSession', args: [sessionId]);
      debugPrint('SignalR: Left game session: $sessionId');
    } catch (e) {
      debugPrint('SignalR: Error leaving game session: $e');
    }
  }

  /// Play a card
  Future<void> playCard(String sessionId, Map<String, dynamic> cardData) async {
    if (!isConnected || _connection == null) {
      debugPrint('SignalR: Cannot play card - not connected');
      return;
    }

    try {
      await _connection!.invoke('PlayCard', args: [sessionId, cardData]);
      debugPrint('SignalR: Played card in session: $sessionId');
    } catch (e) {
      debugPrint('SignalR: Error playing card: $e');
    }
  }

  /// Draw a card
  Future<void> drawCard(String sessionId) async {
    if (!isConnected || _connection == null) {
      debugPrint('SignalR: Cannot draw card - not connected');
      return;
    }

    try {
      await _connection!.invoke('DrawCard', args: [sessionId]);
      debugPrint('SignalR: Drew card in session: $sessionId');
    } catch (e) {
      debugPrint('SignalR: Error drawing card: $e');
    }
  }

  /// Send a game message
  Future<void> sendGameMessage(String sessionId, String message) async {
    if (!isConnected || _connection == null) {
      debugPrint('SignalR: Cannot send message - not connected');
      return;
    }

    try {
      await _connection!.invoke('SendGameMessage', args: [sessionId, message]);
      debugPrint('SignalR: Sent message in session: $sessionId');
    } catch (e) {
      debugPrint('SignalR: Error sending message: $e');
    }
  }

  /// Change suit
  Future<void> changeSuit(String sessionId, String newSuit) async {
    if (!isConnected || _connection == null) {
      debugPrint('SignalR: Cannot change suit - not connected');
      return;
    }

    try {
      await _connection!.invoke('ChangeSuit', args: [sessionId, newSuit]);
      debugPrint('SignalR: Changed suit in session: $sessionId');
    } catch (e) {
      debugPrint('SignalR: Error changing suit: $e');
    }
  }

  /// Request game state
  Future<void> requestGameState(String sessionId) async {
    if (!isConnected || _connection == null) {
      debugPrint('SignalR: Cannot request game state - not connected');
      return;
    }

    try {
      await _connection!.invoke('RequestGameState', args: [sessionId]);
      debugPrint('SignalR: Requested game state for session: $sessionId');
    } catch (e) {
      debugPrint('SignalR: Error requesting game state: $e');
    }
  }

  /// Manually reconnect
  Future<void> reconnect() async {
    if (_status == SignalRConnectionStatus.connecting ||
        _status == SignalRConnectionStatus.reconnecting) {
      return; // Already trying to connect
    }

    await disconnect();
    _reconnectAttempts = 0;
    await initialize(accessToken: _accessToken);
  }

  /// Disconnect from SignalR hub
  Future<void> disconnect() async {
    _reconnectTimer?.cancel();

    if (_connection != null) {
      try {
        await _connection!.stop();
        debugPrint('SignalR: Disconnected');
      } catch (e) {
        debugPrint('SignalR: Error during disconnect: $e');
      }
      _connection = null;
    }

    _updateStatus(SignalRConnectionStatus.disconnected);
  }

  /// Dispose resources
  void dispose() {
    _reconnectTimer?.cancel();
    _statusController.close();
    _gameEventController.close();
    _errorEventController.close();
    disconnect();
  }
}
