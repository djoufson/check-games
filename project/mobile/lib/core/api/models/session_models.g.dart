// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameSessionImpl _$$GameSessionImplFromJson(Map<String, dynamic> json) =>
    _$GameSessionImpl(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      maxPlayers: (json['maxPlayers'] as num).toInt(),
      currentPlayerCount: (json['currentPlayerCount'] as num).toInt(),
      status: $enumDecode(_$GameSessionStatusEnumMap, json['status']),
      players: (json['players'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdByUserId: json['createdByUserId'] as String,
      createdByUserName: json['createdByUserName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      canJoin: json['canJoin'] as bool,
      isFull: json['isFull'] as bool,
    );

Map<String, dynamic> _$$GameSessionImplToJson(_$GameSessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'maxPlayers': instance.maxPlayers,
      'currentPlayerCount': instance.currentPlayerCount,
      'status': _$GameSessionStatusEnumMap[instance.status]!,
      'players': instance.players,
      'createdByUserId': instance.createdByUserId,
      'createdByUserName': instance.createdByUserName,
      'createdAt': instance.createdAt.toIso8601String(),
      'startedAt': instance.startedAt?.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'canJoin': instance.canJoin,
      'isFull': instance.isFull,
    };

const _$GameSessionStatusEnumMap = {
  GameSessionStatus.waitingForPlayers: 0,
  GameSessionStatus.inProgress: 1,
  GameSessionStatus.completed: 2,
  GameSessionStatus.cancelled: 3,
};

_$CreateSessionRequestImpl _$$CreateSessionRequestImplFromJson(
  Map<String, dynamic> json,
) => _$CreateSessionRequestImpl(
  description: json['description'] as String?,
  maxPlayersLimit: (json['maxPlayersLimit'] as num).toInt(),
);

Map<String, dynamic> _$$CreateSessionRequestImplToJson(
  _$CreateSessionRequestImpl instance,
) => <String, dynamic>{
  'description': instance.description,
  'maxPlayersLimit': instance.maxPlayersLimit,
};

_$CreateSessionResponseImpl _$$CreateSessionResponseImplFromJson(
  Map<String, dynamic> json,
) => _$CreateSessionResponseImpl(
  session: GameSession.fromJson(json['session'] as Map<String, dynamic>),
  shareableLink: json['shareableLink'] as String,
);

Map<String, dynamic> _$$CreateSessionResponseImplToJson(
  _$CreateSessionResponseImpl instance,
) => <String, dynamic>{
  'session': instance.session,
  'shareableLink': instance.shareableLink,
};

_$JoinSessionRequestImpl _$$JoinSessionRequestImplFromJson(
  Map<String, dynamic> json,
) => _$JoinSessionRequestImpl(playerName: json['playerName'] as String?);

Map<String, dynamic> _$$JoinSessionRequestImplToJson(
  _$JoinSessionRequestImpl instance,
) => <String, dynamic>{'playerName': instance.playerName};

_$JoinSessionResponseImpl _$$JoinSessionResponseImplFromJson(
  Map<String, dynamic> json,
) => _$JoinSessionResponseImpl(
  sessionId: json['sessionId'] as String,
  assignedPlayerName: json['assignedPlayerName'] as String,
  session: GameSession.fromJson(json['session'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$JoinSessionResponseImplToJson(
  _$JoinSessionResponseImpl instance,
) => <String, dynamic>{
  'sessionId': instance.sessionId,
  'assignedPlayerName': instance.assignedPlayerName,
  'session': instance.session,
};

_$LeaveSessionRequestImpl _$$LeaveSessionRequestImplFromJson(
  Map<String, dynamic> json,
) => _$LeaveSessionRequestImpl(sessionId: json['sessionId'] as String);

Map<String, dynamic> _$$LeaveSessionRequestImplToJson(
  _$LeaveSessionRequestImpl instance,
) => <String, dynamic>{'sessionId': instance.sessionId};

_$GameSessionListResponseImpl _$$GameSessionListResponseImplFromJson(
  Map<String, dynamic> json,
) => _$GameSessionListResponseImpl(
  sessions: (json['sessions'] as List<dynamic>)
      .map((e) => GameSession.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalCount: (json['totalCount'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  pageSize: (json['pageSize'] as num).toInt(),
);

Map<String, dynamic> _$$GameSessionListResponseImplToJson(
  _$GameSessionListResponseImpl instance,
) => <String, dynamic>{
  'sessions': instance.sessions,
  'totalCount': instance.totalCount,
  'page': instance.page,
  'pageSize': instance.pageSize,
};
