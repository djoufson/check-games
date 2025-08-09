import 'package:freezed_annotation/freezed_annotation.dart';

part 'signalr_events.freezed.dart';
part 'signalr_events.g.dart';

/// Base interface for all SignalR events
abstract class SignalREvent {
  DateTime get timestamp;
}

/// Connection Events
@freezed
class PlayerJoinedEvent with _$PlayerJoinedEvent implements SignalREvent {
  const factory PlayerJoinedEvent({
    required String userId,
    required String userName,
    required String sessionId,
    required DateTime timestamp,
  }) = _PlayerJoinedEvent;

  factory PlayerJoinedEvent.fromJson(Map<String, dynamic> json) => _$PlayerJoinedEventFromJson(json);
}

@freezed
class PlayerLeftEvent with _$PlayerLeftEvent implements SignalREvent {
  const factory PlayerLeftEvent({
    required String userId,
    required String userName,
    required String sessionId,
    required DateTime timestamp,
  }) = _PlayerLeftEvent;

  factory PlayerLeftEvent.fromJson(Map<String, dynamic> json) => _$PlayerLeftEventFromJson(json);
}

/// Game Action Events
@freezed
class CardPlayedEvent with _$CardPlayedEvent implements SignalREvent {
  const factory CardPlayedEvent({
    required String userId,
    required String userName,
    required String sessionId,
    required Map<String, dynamic> card, // Flexible card data structure
    required DateTime timestamp,
  }) = _CardPlayedEvent;

  factory CardPlayedEvent.fromJson(Map<String, dynamic> json) => _$CardPlayedEventFromJson(json);
}

@freezed
class CardDrawnEvent with _$CardDrawnEvent implements SignalREvent {
  const factory CardDrawnEvent({
    required String userId,
    required String userName,
    required String sessionId,
    required int cardCount,
    required DateTime timestamp,
  }) = _CardDrawnEvent;

  factory CardDrawnEvent.fromJson(Map<String, dynamic> json) => _$CardDrawnEventFromJson(json);
}

@freezed
class SuitChangedEvent with _$SuitChangedEvent implements SignalREvent {
  const factory SuitChangedEvent({
    required String userId,
    required String userName,
    required String sessionId,
    required String newSuit,
    required DateTime timestamp,
  }) = _SuitChangedEvent;

  factory SuitChangedEvent.fromJson(Map<String, dynamic> json) => _$SuitChangedEventFromJson(json);
}

/// Game State Events
@freezed
class GameStateUpdatedEvent with _$GameStateUpdatedEvent implements SignalREvent {
  const factory GameStateUpdatedEvent({
    required String sessionId,
    required Map<String, dynamic> gameState, // Flexible game state structure
    required DateTime timestamp,
  }) = _GameStateUpdatedEvent;

  factory GameStateUpdatedEvent.fromJson(Map<String, dynamic> json) => _$GameStateUpdatedEventFromJson(json);
}

@freezed
class GameStartedEvent with _$GameStartedEvent implements SignalREvent {
  const factory GameStartedEvent({
    required String sessionId,
    required List<String> playerIds,
    required DateTime timestamp,
  }) = _GameStartedEvent;

  factory GameStartedEvent.fromJson(Map<String, dynamic> json) => _$GameStartedEventFromJson(json);
}

@freezed
class GameEndedEvent with _$GameEndedEvent implements SignalREvent {
  const factory GameEndedEvent({
    required String sessionId,
    required String winnerId,
    required List<String> playerRanking,
    required DateTime timestamp,
  }) = _GameEndedEvent;

  factory GameEndedEvent.fromJson(Map<String, dynamic> json) => _$GameEndedEventFromJson(json);
}

@freezed
class TurnChangedEvent with _$TurnChangedEvent implements SignalREvent {
  const factory TurnChangedEvent({
    required String sessionId,
    required String currentPlayerId,
    required String nextPlayerId,
    required DateTime timestamp,
  }) = _TurnChangedEvent;

  factory TurnChangedEvent.fromJson(Map<String, dynamic> json) => _$TurnChangedEventFromJson(json);
}

/// Communication Events
@freezed
class GameMessageEvent with _$GameMessageEvent implements SignalREvent {
  const factory GameMessageEvent({
    required String userId,
    required String userName,
    required String sessionId,
    required String message,
    required DateTime timestamp,
  }) = _GameMessageEvent;

  factory GameMessageEvent.fromJson(Map<String, dynamic> json) => _$GameMessageEventFromJson(json);
}

/// Error Event
@freezed
class SignalRErrorEvent with _$SignalRErrorEvent {
  const factory SignalRErrorEvent({
    required String message,
  }) = _SignalRErrorEvent;

  factory SignalRErrorEvent.fromJson(Map<String, dynamic> json) => _$SignalRErrorEventFromJson(json);
}

/// Utility class for parsing SignalR events
class SignalREventParser {
  static SignalREvent? parseEvent(String eventType, Map<String, dynamic> data) {
    switch (eventType) {
      case 'PlayerJoined':
        return PlayerJoinedEvent.fromJson(data);
      case 'PlayerLeft':
        return PlayerLeftEvent.fromJson(data);
      case 'CardPlayed':
        return CardPlayedEvent.fromJson(data);
      case 'CardDrawn':
        return CardDrawnEvent.fromJson(data);
      case 'SuitChanged':
        return SuitChangedEvent.fromJson(data);
      case 'GameStateUpdated':
        return GameStateUpdatedEvent.fromJson(data);
      case 'GameStarted':
        return GameStartedEvent.fromJson(data);
      case 'GameEnded':
        return GameEndedEvent.fromJson(data);
      case 'TurnChanged':
        return TurnChangedEvent.fromJson(data);
      case 'GameMessage':
        return GameMessageEvent.fromJson(data);
      default:
        return null;
    }
  }

  static SignalRErrorEvent? parseError(String message) {
    return SignalRErrorEvent(message: message);
  }
}