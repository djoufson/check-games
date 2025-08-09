// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signalr_events.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlayerJoinedEventImpl _$$PlayerJoinedEventImplFromJson(
  Map<String, dynamic> json,
) => _$PlayerJoinedEventImpl(
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  sessionId: json['sessionId'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$$PlayerJoinedEventImplToJson(
  _$PlayerJoinedEventImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'userName': instance.userName,
  'sessionId': instance.sessionId,
  'timestamp': instance.timestamp.toIso8601String(),
};

_$PlayerLeftEventImpl _$$PlayerLeftEventImplFromJson(
  Map<String, dynamic> json,
) => _$PlayerLeftEventImpl(
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  sessionId: json['sessionId'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$$PlayerLeftEventImplToJson(
  _$PlayerLeftEventImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'userName': instance.userName,
  'sessionId': instance.sessionId,
  'timestamp': instance.timestamp.toIso8601String(),
};

_$CardPlayedEventImpl _$$CardPlayedEventImplFromJson(
  Map<String, dynamic> json,
) => _$CardPlayedEventImpl(
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  sessionId: json['sessionId'] as String,
  card: json['card'] as Map<String, dynamic>,
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$$CardPlayedEventImplToJson(
  _$CardPlayedEventImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'userName': instance.userName,
  'sessionId': instance.sessionId,
  'card': instance.card,
  'timestamp': instance.timestamp.toIso8601String(),
};

_$CardDrawnEventImpl _$$CardDrawnEventImplFromJson(Map<String, dynamic> json) =>
    _$CardDrawnEventImpl(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      sessionId: json['sessionId'] as String,
      cardCount: (json['cardCount'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$CardDrawnEventImplToJson(
  _$CardDrawnEventImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'userName': instance.userName,
  'sessionId': instance.sessionId,
  'cardCount': instance.cardCount,
  'timestamp': instance.timestamp.toIso8601String(),
};

_$SuitChangedEventImpl _$$SuitChangedEventImplFromJson(
  Map<String, dynamic> json,
) => _$SuitChangedEventImpl(
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  sessionId: json['sessionId'] as String,
  newSuit: json['newSuit'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$$SuitChangedEventImplToJson(
  _$SuitChangedEventImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'userName': instance.userName,
  'sessionId': instance.sessionId,
  'newSuit': instance.newSuit,
  'timestamp': instance.timestamp.toIso8601String(),
};

_$GameStateUpdatedEventImpl _$$GameStateUpdatedEventImplFromJson(
  Map<String, dynamic> json,
) => _$GameStateUpdatedEventImpl(
  sessionId: json['sessionId'] as String,
  gameState: json['gameState'] as Map<String, dynamic>,
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$$GameStateUpdatedEventImplToJson(
  _$GameStateUpdatedEventImpl instance,
) => <String, dynamic>{
  'sessionId': instance.sessionId,
  'gameState': instance.gameState,
  'timestamp': instance.timestamp.toIso8601String(),
};

_$GameStartedEventImpl _$$GameStartedEventImplFromJson(
  Map<String, dynamic> json,
) => _$GameStartedEventImpl(
  sessionId: json['sessionId'] as String,
  playerIds: (json['playerIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$$GameStartedEventImplToJson(
  _$GameStartedEventImpl instance,
) => <String, dynamic>{
  'sessionId': instance.sessionId,
  'playerIds': instance.playerIds,
  'timestamp': instance.timestamp.toIso8601String(),
};

_$GameEndedEventImpl _$$GameEndedEventImplFromJson(Map<String, dynamic> json) =>
    _$GameEndedEventImpl(
      sessionId: json['sessionId'] as String,
      winnerId: json['winnerId'] as String,
      playerRanking: (json['playerRanking'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$GameEndedEventImplToJson(
  _$GameEndedEventImpl instance,
) => <String, dynamic>{
  'sessionId': instance.sessionId,
  'winnerId': instance.winnerId,
  'playerRanking': instance.playerRanking,
  'timestamp': instance.timestamp.toIso8601String(),
};

_$TurnChangedEventImpl _$$TurnChangedEventImplFromJson(
  Map<String, dynamic> json,
) => _$TurnChangedEventImpl(
  sessionId: json['sessionId'] as String,
  currentPlayerId: json['currentPlayerId'] as String,
  nextPlayerId: json['nextPlayerId'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$$TurnChangedEventImplToJson(
  _$TurnChangedEventImpl instance,
) => <String, dynamic>{
  'sessionId': instance.sessionId,
  'currentPlayerId': instance.currentPlayerId,
  'nextPlayerId': instance.nextPlayerId,
  'timestamp': instance.timestamp.toIso8601String(),
};

_$GameMessageEventImpl _$$GameMessageEventImplFromJson(
  Map<String, dynamic> json,
) => _$GameMessageEventImpl(
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  sessionId: json['sessionId'] as String,
  message: json['message'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$$GameMessageEventImplToJson(
  _$GameMessageEventImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'userName': instance.userName,
  'sessionId': instance.sessionId,
  'message': instance.message,
  'timestamp': instance.timestamp.toIso8601String(),
};

_$SignalRErrorEventImpl _$$SignalRErrorEventImplFromJson(
  Map<String, dynamic> json,
) => _$SignalRErrorEventImpl(message: json['message'] as String);

Map<String, dynamic> _$$SignalRErrorEventImplToJson(
  _$SignalRErrorEventImpl instance,
) => <String, dynamic>{'message': instance.message};
