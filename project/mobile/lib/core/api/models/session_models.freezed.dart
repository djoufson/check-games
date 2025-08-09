// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GameSession _$GameSessionFromJson(Map<String, dynamic> json) {
  return _GameSession.fromJson(json);
}

/// @nodoc
mixin _$GameSession {
  String get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get maxPlayers => throw _privateConstructorUsedError;
  int get currentPlayerCount => throw _privateConstructorUsedError;
  GameSessionStatus get status => throw _privateConstructorUsedError;
  List<String> get players => throw _privateConstructorUsedError;
  String get createdByUserId => throw _privateConstructorUsedError;
  String? get createdByUserName => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get endedAt => throw _privateConstructorUsedError;
  bool get canJoin => throw _privateConstructorUsedError;
  bool get isFull => throw _privateConstructorUsedError;

  /// Serializes this GameSession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameSessionCopyWith<GameSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameSessionCopyWith<$Res> {
  factory $GameSessionCopyWith(
    GameSession value,
    $Res Function(GameSession) then,
  ) = _$GameSessionCopyWithImpl<$Res, GameSession>;
  @useResult
  $Res call({
    String id,
    String code,
    String name,
    int maxPlayers,
    int currentPlayerCount,
    GameSessionStatus status,
    List<String> players,
    String createdByUserId,
    String? createdByUserName,
    DateTime createdAt,
    DateTime? startedAt,
    DateTime? endedAt,
    bool canJoin,
    bool isFull,
  });
}

/// @nodoc
class _$GameSessionCopyWithImpl<$Res, $Val extends GameSession>
    implements $GameSessionCopyWith<$Res> {
  _$GameSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? maxPlayers = null,
    Object? currentPlayerCount = null,
    Object? status = null,
    Object? players = null,
    Object? createdByUserId = null,
    Object? createdByUserName = freezed,
    Object? createdAt = null,
    Object? startedAt = freezed,
    Object? endedAt = freezed,
    Object? canJoin = null,
    Object? isFull = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            maxPlayers: null == maxPlayers
                ? _value.maxPlayers
                : maxPlayers // ignore: cast_nullable_to_non_nullable
                      as int,
            currentPlayerCount: null == currentPlayerCount
                ? _value.currentPlayerCount
                : currentPlayerCount // ignore: cast_nullable_to_non_nullable
                      as int,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as GameSessionStatus,
            players: null == players
                ? _value.players
                : players // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            createdByUserId: null == createdByUserId
                ? _value.createdByUserId
                : createdByUserId // ignore: cast_nullable_to_non_nullable
                      as String,
            createdByUserName: freezed == createdByUserName
                ? _value.createdByUserName
                : createdByUserName // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            endedAt: freezed == endedAt
                ? _value.endedAt
                : endedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            canJoin: null == canJoin
                ? _value.canJoin
                : canJoin // ignore: cast_nullable_to_non_nullable
                      as bool,
            isFull: null == isFull
                ? _value.isFull
                : isFull // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameSessionImplCopyWith<$Res>
    implements $GameSessionCopyWith<$Res> {
  factory _$$GameSessionImplCopyWith(
    _$GameSessionImpl value,
    $Res Function(_$GameSessionImpl) then,
  ) = __$$GameSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String code,
    String name,
    int maxPlayers,
    int currentPlayerCount,
    GameSessionStatus status,
    List<String> players,
    String createdByUserId,
    String? createdByUserName,
    DateTime createdAt,
    DateTime? startedAt,
    DateTime? endedAt,
    bool canJoin,
    bool isFull,
  });
}

/// @nodoc
class __$$GameSessionImplCopyWithImpl<$Res>
    extends _$GameSessionCopyWithImpl<$Res, _$GameSessionImpl>
    implements _$$GameSessionImplCopyWith<$Res> {
  __$$GameSessionImplCopyWithImpl(
    _$GameSessionImpl _value,
    $Res Function(_$GameSessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? maxPlayers = null,
    Object? currentPlayerCount = null,
    Object? status = null,
    Object? players = null,
    Object? createdByUserId = null,
    Object? createdByUserName = freezed,
    Object? createdAt = null,
    Object? startedAt = freezed,
    Object? endedAt = freezed,
    Object? canJoin = null,
    Object? isFull = null,
  }) {
    return _then(
      _$GameSessionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        maxPlayers: null == maxPlayers
            ? _value.maxPlayers
            : maxPlayers // ignore: cast_nullable_to_non_nullable
                  as int,
        currentPlayerCount: null == currentPlayerCount
            ? _value.currentPlayerCount
            : currentPlayerCount // ignore: cast_nullable_to_non_nullable
                  as int,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as GameSessionStatus,
        players: null == players
            ? _value._players
            : players // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        createdByUserId: null == createdByUserId
            ? _value.createdByUserId
            : createdByUserId // ignore: cast_nullable_to_non_nullable
                  as String,
        createdByUserName: freezed == createdByUserName
            ? _value.createdByUserName
            : createdByUserName // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        endedAt: freezed == endedAt
            ? _value.endedAt
            : endedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        canJoin: null == canJoin
            ? _value.canJoin
            : canJoin // ignore: cast_nullable_to_non_nullable
                  as bool,
        isFull: null == isFull
            ? _value.isFull
            : isFull // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameSessionImpl implements _GameSession {
  const _$GameSessionImpl({
    required this.id,
    required this.code,
    required this.name,
    required this.maxPlayers,
    required this.currentPlayerCount,
    required this.status,
    required final List<String> players,
    required this.createdByUserId,
    this.createdByUserName,
    required this.createdAt,
    this.startedAt,
    this.endedAt,
    required this.canJoin,
    required this.isFull,
  }) : _players = players;

  factory _$GameSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameSessionImplFromJson(json);

  @override
  final String id;
  @override
  final String code;
  @override
  final String name;
  @override
  final int maxPlayers;
  @override
  final int currentPlayerCount;
  @override
  final GameSessionStatus status;
  final List<String> _players;
  @override
  List<String> get players {
    if (_players is EqualUnmodifiableListView) return _players;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_players);
  }

  @override
  final String createdByUserId;
  @override
  final String? createdByUserName;
  @override
  final DateTime createdAt;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? endedAt;
  @override
  final bool canJoin;
  @override
  final bool isFull;

  @override
  String toString() {
    return 'GameSession(id: $id, code: $code, name: $name, maxPlayers: $maxPlayers, currentPlayerCount: $currentPlayerCount, status: $status, players: $players, createdByUserId: $createdByUserId, createdByUserName: $createdByUserName, createdAt: $createdAt, startedAt: $startedAt, endedAt: $endedAt, canJoin: $canJoin, isFull: $isFull)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.maxPlayers, maxPlayers) ||
                other.maxPlayers == maxPlayers) &&
            (identical(other.currentPlayerCount, currentPlayerCount) ||
                other.currentPlayerCount == currentPlayerCount) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._players, _players) &&
            (identical(other.createdByUserId, createdByUserId) ||
                other.createdByUserId == createdByUserId) &&
            (identical(other.createdByUserName, createdByUserName) ||
                other.createdByUserName == createdByUserName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt) &&
            (identical(other.canJoin, canJoin) || other.canJoin == canJoin) &&
            (identical(other.isFull, isFull) || other.isFull == isFull));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    code,
    name,
    maxPlayers,
    currentPlayerCount,
    status,
    const DeepCollectionEquality().hash(_players),
    createdByUserId,
    createdByUserName,
    createdAt,
    startedAt,
    endedAt,
    canJoin,
    isFull,
  );

  /// Create a copy of GameSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameSessionImplCopyWith<_$GameSessionImpl> get copyWith =>
      __$$GameSessionImplCopyWithImpl<_$GameSessionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameSessionImplToJson(this);
  }
}

abstract class _GameSession implements GameSession {
  const factory _GameSession({
    required final String id,
    required final String code,
    required final String name,
    required final int maxPlayers,
    required final int currentPlayerCount,
    required final GameSessionStatus status,
    required final List<String> players,
    required final String createdByUserId,
    final String? createdByUserName,
    required final DateTime createdAt,
    final DateTime? startedAt,
    final DateTime? endedAt,
    required final bool canJoin,
    required final bool isFull,
  }) = _$GameSessionImpl;

  factory _GameSession.fromJson(Map<String, dynamic> json) =
      _$GameSessionImpl.fromJson;

  @override
  String get id;
  @override
  String get code;
  @override
  String get name;
  @override
  int get maxPlayers;
  @override
  int get currentPlayerCount;
  @override
  GameSessionStatus get status;
  @override
  List<String> get players;
  @override
  String get createdByUserId;
  @override
  String? get createdByUserName;
  @override
  DateTime get createdAt;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get endedAt;
  @override
  bool get canJoin;
  @override
  bool get isFull;

  /// Create a copy of GameSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameSessionImplCopyWith<_$GameSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateSessionRequest _$CreateSessionRequestFromJson(Map<String, dynamic> json) {
  return _CreateSessionRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateSessionRequest {
  String? get description => throw _privateConstructorUsedError;
  int get maxPlayersLimit => throw _privateConstructorUsedError;

  /// Serializes this CreateSessionRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateSessionRequestCopyWith<CreateSessionRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateSessionRequestCopyWith<$Res> {
  factory $CreateSessionRequestCopyWith(
    CreateSessionRequest value,
    $Res Function(CreateSessionRequest) then,
  ) = _$CreateSessionRequestCopyWithImpl<$Res, CreateSessionRequest>;
  @useResult
  $Res call({String? description, int maxPlayersLimit});
}

/// @nodoc
class _$CreateSessionRequestCopyWithImpl<
  $Res,
  $Val extends CreateSessionRequest
>
    implements $CreateSessionRequestCopyWith<$Res> {
  _$CreateSessionRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? description = freezed, Object? maxPlayersLimit = null}) {
    return _then(
      _value.copyWith(
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            maxPlayersLimit: null == maxPlayersLimit
                ? _value.maxPlayersLimit
                : maxPlayersLimit // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateSessionRequestImplCopyWith<$Res>
    implements $CreateSessionRequestCopyWith<$Res> {
  factory _$$CreateSessionRequestImplCopyWith(
    _$CreateSessionRequestImpl value,
    $Res Function(_$CreateSessionRequestImpl) then,
  ) = __$$CreateSessionRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? description, int maxPlayersLimit});
}

/// @nodoc
class __$$CreateSessionRequestImplCopyWithImpl<$Res>
    extends _$CreateSessionRequestCopyWithImpl<$Res, _$CreateSessionRequestImpl>
    implements _$$CreateSessionRequestImplCopyWith<$Res> {
  __$$CreateSessionRequestImplCopyWithImpl(
    _$CreateSessionRequestImpl _value,
    $Res Function(_$CreateSessionRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? description = freezed, Object? maxPlayersLimit = null}) {
    return _then(
      _$CreateSessionRequestImpl(
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        maxPlayersLimit: null == maxPlayersLimit
            ? _value.maxPlayersLimit
            : maxPlayersLimit // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateSessionRequestImpl implements _CreateSessionRequest {
  const _$CreateSessionRequestImpl({
    this.description,
    required this.maxPlayersLimit,
  });

  factory _$CreateSessionRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateSessionRequestImplFromJson(json);

  @override
  final String? description;
  @override
  final int maxPlayersLimit;

  @override
  String toString() {
    return 'CreateSessionRequest(description: $description, maxPlayersLimit: $maxPlayersLimit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateSessionRequestImpl &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.maxPlayersLimit, maxPlayersLimit) ||
                other.maxPlayersLimit == maxPlayersLimit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, description, maxPlayersLimit);

  /// Create a copy of CreateSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateSessionRequestImplCopyWith<_$CreateSessionRequestImpl>
  get copyWith =>
      __$$CreateSessionRequestImplCopyWithImpl<_$CreateSessionRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateSessionRequestImplToJson(this);
  }
}

abstract class _CreateSessionRequest implements CreateSessionRequest {
  const factory _CreateSessionRequest({
    final String? description,
    required final int maxPlayersLimit,
  }) = _$CreateSessionRequestImpl;

  factory _CreateSessionRequest.fromJson(Map<String, dynamic> json) =
      _$CreateSessionRequestImpl.fromJson;

  @override
  String? get description;
  @override
  int get maxPlayersLimit;

  /// Create a copy of CreateSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateSessionRequestImplCopyWith<_$CreateSessionRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

CreateSessionResponse _$CreateSessionResponseFromJson(
  Map<String, dynamic> json,
) {
  return _CreateSessionResponse.fromJson(json);
}

/// @nodoc
mixin _$CreateSessionResponse {
  GameSession get session => throw _privateConstructorUsedError;
  String get shareableLink => throw _privateConstructorUsedError;

  /// Serializes this CreateSessionResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateSessionResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateSessionResponseCopyWith<CreateSessionResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateSessionResponseCopyWith<$Res> {
  factory $CreateSessionResponseCopyWith(
    CreateSessionResponse value,
    $Res Function(CreateSessionResponse) then,
  ) = _$CreateSessionResponseCopyWithImpl<$Res, CreateSessionResponse>;
  @useResult
  $Res call({GameSession session, String shareableLink});

  $GameSessionCopyWith<$Res> get session;
}

/// @nodoc
class _$CreateSessionResponseCopyWithImpl<
  $Res,
  $Val extends CreateSessionResponse
>
    implements $CreateSessionResponseCopyWith<$Res> {
  _$CreateSessionResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateSessionResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? session = null, Object? shareableLink = null}) {
    return _then(
      _value.copyWith(
            session: null == session
                ? _value.session
                : session // ignore: cast_nullable_to_non_nullable
                      as GameSession,
            shareableLink: null == shareableLink
                ? _value.shareableLink
                : shareableLink // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of CreateSessionResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GameSessionCopyWith<$Res> get session {
    return $GameSessionCopyWith<$Res>(_value.session, (value) {
      return _then(_value.copyWith(session: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CreateSessionResponseImplCopyWith<$Res>
    implements $CreateSessionResponseCopyWith<$Res> {
  factory _$$CreateSessionResponseImplCopyWith(
    _$CreateSessionResponseImpl value,
    $Res Function(_$CreateSessionResponseImpl) then,
  ) = __$$CreateSessionResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({GameSession session, String shareableLink});

  @override
  $GameSessionCopyWith<$Res> get session;
}

/// @nodoc
class __$$CreateSessionResponseImplCopyWithImpl<$Res>
    extends
        _$CreateSessionResponseCopyWithImpl<$Res, _$CreateSessionResponseImpl>
    implements _$$CreateSessionResponseImplCopyWith<$Res> {
  __$$CreateSessionResponseImplCopyWithImpl(
    _$CreateSessionResponseImpl _value,
    $Res Function(_$CreateSessionResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateSessionResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? session = null, Object? shareableLink = null}) {
    return _then(
      _$CreateSessionResponseImpl(
        session: null == session
            ? _value.session
            : session // ignore: cast_nullable_to_non_nullable
                  as GameSession,
        shareableLink: null == shareableLink
            ? _value.shareableLink
            : shareableLink // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateSessionResponseImpl implements _CreateSessionResponse {
  const _$CreateSessionResponseImpl({
    required this.session,
    required this.shareableLink,
  });

  factory _$CreateSessionResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateSessionResponseImplFromJson(json);

  @override
  final GameSession session;
  @override
  final String shareableLink;

  @override
  String toString() {
    return 'CreateSessionResponse(session: $session, shareableLink: $shareableLink)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateSessionResponseImpl &&
            (identical(other.session, session) || other.session == session) &&
            (identical(other.shareableLink, shareableLink) ||
                other.shareableLink == shareableLink));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, session, shareableLink);

  /// Create a copy of CreateSessionResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateSessionResponseImplCopyWith<_$CreateSessionResponseImpl>
  get copyWith =>
      __$$CreateSessionResponseImplCopyWithImpl<_$CreateSessionResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateSessionResponseImplToJson(this);
  }
}

abstract class _CreateSessionResponse implements CreateSessionResponse {
  const factory _CreateSessionResponse({
    required final GameSession session,
    required final String shareableLink,
  }) = _$CreateSessionResponseImpl;

  factory _CreateSessionResponse.fromJson(Map<String, dynamic> json) =
      _$CreateSessionResponseImpl.fromJson;

  @override
  GameSession get session;
  @override
  String get shareableLink;

  /// Create a copy of CreateSessionResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateSessionResponseImplCopyWith<_$CreateSessionResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

JoinSessionRequest _$JoinSessionRequestFromJson(Map<String, dynamic> json) {
  return _JoinSessionRequest.fromJson(json);
}

/// @nodoc
mixin _$JoinSessionRequest {
  String? get playerName => throw _privateConstructorUsedError;

  /// Serializes this JoinSessionRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of JoinSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JoinSessionRequestCopyWith<JoinSessionRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JoinSessionRequestCopyWith<$Res> {
  factory $JoinSessionRequestCopyWith(
    JoinSessionRequest value,
    $Res Function(JoinSessionRequest) then,
  ) = _$JoinSessionRequestCopyWithImpl<$Res, JoinSessionRequest>;
  @useResult
  $Res call({String? playerName});
}

/// @nodoc
class _$JoinSessionRequestCopyWithImpl<$Res, $Val extends JoinSessionRequest>
    implements $JoinSessionRequestCopyWith<$Res> {
  _$JoinSessionRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JoinSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? playerName = freezed}) {
    return _then(
      _value.copyWith(
            playerName: freezed == playerName
                ? _value.playerName
                : playerName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$JoinSessionRequestImplCopyWith<$Res>
    implements $JoinSessionRequestCopyWith<$Res> {
  factory _$$JoinSessionRequestImplCopyWith(
    _$JoinSessionRequestImpl value,
    $Res Function(_$JoinSessionRequestImpl) then,
  ) = __$$JoinSessionRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? playerName});
}

/// @nodoc
class __$$JoinSessionRequestImplCopyWithImpl<$Res>
    extends _$JoinSessionRequestCopyWithImpl<$Res, _$JoinSessionRequestImpl>
    implements _$$JoinSessionRequestImplCopyWith<$Res> {
  __$$JoinSessionRequestImplCopyWithImpl(
    _$JoinSessionRequestImpl _value,
    $Res Function(_$JoinSessionRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JoinSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? playerName = freezed}) {
    return _then(
      _$JoinSessionRequestImpl(
        playerName: freezed == playerName
            ? _value.playerName
            : playerName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$JoinSessionRequestImpl implements _JoinSessionRequest {
  const _$JoinSessionRequestImpl({this.playerName});

  factory _$JoinSessionRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$JoinSessionRequestImplFromJson(json);

  @override
  final String? playerName;

  @override
  String toString() {
    return 'JoinSessionRequest(playerName: $playerName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JoinSessionRequestImpl &&
            (identical(other.playerName, playerName) ||
                other.playerName == playerName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, playerName);

  /// Create a copy of JoinSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JoinSessionRequestImplCopyWith<_$JoinSessionRequestImpl> get copyWith =>
      __$$JoinSessionRequestImplCopyWithImpl<_$JoinSessionRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$JoinSessionRequestImplToJson(this);
  }
}

abstract class _JoinSessionRequest implements JoinSessionRequest {
  const factory _JoinSessionRequest({final String? playerName}) =
      _$JoinSessionRequestImpl;

  factory _JoinSessionRequest.fromJson(Map<String, dynamic> json) =
      _$JoinSessionRequestImpl.fromJson;

  @override
  String? get playerName;

  /// Create a copy of JoinSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JoinSessionRequestImplCopyWith<_$JoinSessionRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

JoinSessionResponse _$JoinSessionResponseFromJson(Map<String, dynamic> json) {
  return _JoinSessionResponse.fromJson(json);
}

/// @nodoc
mixin _$JoinSessionResponse {
  String get sessionId => throw _privateConstructorUsedError;
  String get assignedPlayerName => throw _privateConstructorUsedError;
  GameSession get session => throw _privateConstructorUsedError;

  /// Serializes this JoinSessionResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of JoinSessionResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $JoinSessionResponseCopyWith<JoinSessionResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JoinSessionResponseCopyWith<$Res> {
  factory $JoinSessionResponseCopyWith(
    JoinSessionResponse value,
    $Res Function(JoinSessionResponse) then,
  ) = _$JoinSessionResponseCopyWithImpl<$Res, JoinSessionResponse>;
  @useResult
  $Res call({String sessionId, String assignedPlayerName, GameSession session});

  $GameSessionCopyWith<$Res> get session;
}

/// @nodoc
class _$JoinSessionResponseCopyWithImpl<$Res, $Val extends JoinSessionResponse>
    implements $JoinSessionResponseCopyWith<$Res> {
  _$JoinSessionResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of JoinSessionResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? assignedPlayerName = null,
    Object? session = null,
  }) {
    return _then(
      _value.copyWith(
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            assignedPlayerName: null == assignedPlayerName
                ? _value.assignedPlayerName
                : assignedPlayerName // ignore: cast_nullable_to_non_nullable
                      as String,
            session: null == session
                ? _value.session
                : session // ignore: cast_nullable_to_non_nullable
                      as GameSession,
          )
          as $Val,
    );
  }

  /// Create a copy of JoinSessionResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GameSessionCopyWith<$Res> get session {
    return $GameSessionCopyWith<$Res>(_value.session, (value) {
      return _then(_value.copyWith(session: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$JoinSessionResponseImplCopyWith<$Res>
    implements $JoinSessionResponseCopyWith<$Res> {
  factory _$$JoinSessionResponseImplCopyWith(
    _$JoinSessionResponseImpl value,
    $Res Function(_$JoinSessionResponseImpl) then,
  ) = __$$JoinSessionResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String sessionId, String assignedPlayerName, GameSession session});

  @override
  $GameSessionCopyWith<$Res> get session;
}

/// @nodoc
class __$$JoinSessionResponseImplCopyWithImpl<$Res>
    extends _$JoinSessionResponseCopyWithImpl<$Res, _$JoinSessionResponseImpl>
    implements _$$JoinSessionResponseImplCopyWith<$Res> {
  __$$JoinSessionResponseImplCopyWithImpl(
    _$JoinSessionResponseImpl _value,
    $Res Function(_$JoinSessionResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of JoinSessionResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? assignedPlayerName = null,
    Object? session = null,
  }) {
    return _then(
      _$JoinSessionResponseImpl(
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        assignedPlayerName: null == assignedPlayerName
            ? _value.assignedPlayerName
            : assignedPlayerName // ignore: cast_nullable_to_non_nullable
                  as String,
        session: null == session
            ? _value.session
            : session // ignore: cast_nullable_to_non_nullable
                  as GameSession,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$JoinSessionResponseImpl implements _JoinSessionResponse {
  const _$JoinSessionResponseImpl({
    required this.sessionId,
    required this.assignedPlayerName,
    required this.session,
  });

  factory _$JoinSessionResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$JoinSessionResponseImplFromJson(json);

  @override
  final String sessionId;
  @override
  final String assignedPlayerName;
  @override
  final GameSession session;

  @override
  String toString() {
    return 'JoinSessionResponse(sessionId: $sessionId, assignedPlayerName: $assignedPlayerName, session: $session)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JoinSessionResponseImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.assignedPlayerName, assignedPlayerName) ||
                other.assignedPlayerName == assignedPlayerName) &&
            (identical(other.session, session) || other.session == session));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, sessionId, assignedPlayerName, session);

  /// Create a copy of JoinSessionResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$JoinSessionResponseImplCopyWith<_$JoinSessionResponseImpl> get copyWith =>
      __$$JoinSessionResponseImplCopyWithImpl<_$JoinSessionResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$JoinSessionResponseImplToJson(this);
  }
}

abstract class _JoinSessionResponse implements JoinSessionResponse {
  const factory _JoinSessionResponse({
    required final String sessionId,
    required final String assignedPlayerName,
    required final GameSession session,
  }) = _$JoinSessionResponseImpl;

  factory _JoinSessionResponse.fromJson(Map<String, dynamic> json) =
      _$JoinSessionResponseImpl.fromJson;

  @override
  String get sessionId;
  @override
  String get assignedPlayerName;
  @override
  GameSession get session;

  /// Create a copy of JoinSessionResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$JoinSessionResponseImplCopyWith<_$JoinSessionResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LeaveSessionRequest _$LeaveSessionRequestFromJson(Map<String, dynamic> json) {
  return _LeaveSessionRequest.fromJson(json);
}

/// @nodoc
mixin _$LeaveSessionRequest {
  String get sessionId => throw _privateConstructorUsedError;

  /// Serializes this LeaveSessionRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeaveSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeaveSessionRequestCopyWith<LeaveSessionRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeaveSessionRequestCopyWith<$Res> {
  factory $LeaveSessionRequestCopyWith(
    LeaveSessionRequest value,
    $Res Function(LeaveSessionRequest) then,
  ) = _$LeaveSessionRequestCopyWithImpl<$Res, LeaveSessionRequest>;
  @useResult
  $Res call({String sessionId});
}

/// @nodoc
class _$LeaveSessionRequestCopyWithImpl<$Res, $Val extends LeaveSessionRequest>
    implements $LeaveSessionRequestCopyWith<$Res> {
  _$LeaveSessionRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeaveSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? sessionId = null}) {
    return _then(
      _value.copyWith(
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LeaveSessionRequestImplCopyWith<$Res>
    implements $LeaveSessionRequestCopyWith<$Res> {
  factory _$$LeaveSessionRequestImplCopyWith(
    _$LeaveSessionRequestImpl value,
    $Res Function(_$LeaveSessionRequestImpl) then,
  ) = __$$LeaveSessionRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String sessionId});
}

/// @nodoc
class __$$LeaveSessionRequestImplCopyWithImpl<$Res>
    extends _$LeaveSessionRequestCopyWithImpl<$Res, _$LeaveSessionRequestImpl>
    implements _$$LeaveSessionRequestImplCopyWith<$Res> {
  __$$LeaveSessionRequestImplCopyWithImpl(
    _$LeaveSessionRequestImpl _value,
    $Res Function(_$LeaveSessionRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LeaveSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? sessionId = null}) {
    return _then(
      _$LeaveSessionRequestImpl(
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LeaveSessionRequestImpl implements _LeaveSessionRequest {
  const _$LeaveSessionRequestImpl({required this.sessionId});

  factory _$LeaveSessionRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeaveSessionRequestImplFromJson(json);

  @override
  final String sessionId;

  @override
  String toString() {
    return 'LeaveSessionRequest(sessionId: $sessionId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeaveSessionRequestImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, sessionId);

  /// Create a copy of LeaveSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeaveSessionRequestImplCopyWith<_$LeaveSessionRequestImpl> get copyWith =>
      __$$LeaveSessionRequestImplCopyWithImpl<_$LeaveSessionRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LeaveSessionRequestImplToJson(this);
  }
}

abstract class _LeaveSessionRequest implements LeaveSessionRequest {
  const factory _LeaveSessionRequest({required final String sessionId}) =
      _$LeaveSessionRequestImpl;

  factory _LeaveSessionRequest.fromJson(Map<String, dynamic> json) =
      _$LeaveSessionRequestImpl.fromJson;

  @override
  String get sessionId;

  /// Create a copy of LeaveSessionRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeaveSessionRequestImplCopyWith<_$LeaveSessionRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GameSessionListResponse _$GameSessionListResponseFromJson(
  Map<String, dynamic> json,
) {
  return _GameSessionListResponse.fromJson(json);
}

/// @nodoc
mixin _$GameSessionListResponse {
  List<GameSession> get sessions => throw _privateConstructorUsedError;
  int get totalCount => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get pageSize => throw _privateConstructorUsedError;

  /// Serializes this GameSessionListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameSessionListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameSessionListResponseCopyWith<GameSessionListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameSessionListResponseCopyWith<$Res> {
  factory $GameSessionListResponseCopyWith(
    GameSessionListResponse value,
    $Res Function(GameSessionListResponse) then,
  ) = _$GameSessionListResponseCopyWithImpl<$Res, GameSessionListResponse>;
  @useResult
  $Res call({
    List<GameSession> sessions,
    int totalCount,
    int page,
    int pageSize,
  });
}

/// @nodoc
class _$GameSessionListResponseCopyWithImpl<
  $Res,
  $Val extends GameSessionListResponse
>
    implements $GameSessionListResponseCopyWith<$Res> {
  _$GameSessionListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameSessionListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessions = null,
    Object? totalCount = null,
    Object? page = null,
    Object? pageSize = null,
  }) {
    return _then(
      _value.copyWith(
            sessions: null == sessions
                ? _value.sessions
                : sessions // ignore: cast_nullable_to_non_nullable
                      as List<GameSession>,
            totalCount: null == totalCount
                ? _value.totalCount
                : totalCount // ignore: cast_nullable_to_non_nullable
                      as int,
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            pageSize: null == pageSize
                ? _value.pageSize
                : pageSize // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameSessionListResponseImplCopyWith<$Res>
    implements $GameSessionListResponseCopyWith<$Res> {
  factory _$$GameSessionListResponseImplCopyWith(
    _$GameSessionListResponseImpl value,
    $Res Function(_$GameSessionListResponseImpl) then,
  ) = __$$GameSessionListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<GameSession> sessions,
    int totalCount,
    int page,
    int pageSize,
  });
}

/// @nodoc
class __$$GameSessionListResponseImplCopyWithImpl<$Res>
    extends
        _$GameSessionListResponseCopyWithImpl<
          $Res,
          _$GameSessionListResponseImpl
        >
    implements _$$GameSessionListResponseImplCopyWith<$Res> {
  __$$GameSessionListResponseImplCopyWithImpl(
    _$GameSessionListResponseImpl _value,
    $Res Function(_$GameSessionListResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameSessionListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessions = null,
    Object? totalCount = null,
    Object? page = null,
    Object? pageSize = null,
  }) {
    return _then(
      _$GameSessionListResponseImpl(
        sessions: null == sessions
            ? _value._sessions
            : sessions // ignore: cast_nullable_to_non_nullable
                  as List<GameSession>,
        totalCount: null == totalCount
            ? _value.totalCount
            : totalCount // ignore: cast_nullable_to_non_nullable
                  as int,
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        pageSize: null == pageSize
            ? _value.pageSize
            : pageSize // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameSessionListResponseImpl implements _GameSessionListResponse {
  const _$GameSessionListResponseImpl({
    required final List<GameSession> sessions,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  }) : _sessions = sessions;

  factory _$GameSessionListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameSessionListResponseImplFromJson(json);

  final List<GameSession> _sessions;
  @override
  List<GameSession> get sessions {
    if (_sessions is EqualUnmodifiableListView) return _sessions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sessions);
  }

  @override
  final int totalCount;
  @override
  final int page;
  @override
  final int pageSize;

  @override
  String toString() {
    return 'GameSessionListResponse(sessions: $sessions, totalCount: $totalCount, page: $page, pageSize: $pageSize)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameSessionListResponseImpl &&
            const DeepCollectionEquality().equals(other._sessions, _sessions) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_sessions),
    totalCount,
    page,
    pageSize,
  );

  /// Create a copy of GameSessionListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameSessionListResponseImplCopyWith<_$GameSessionListResponseImpl>
  get copyWith =>
      __$$GameSessionListResponseImplCopyWithImpl<
        _$GameSessionListResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameSessionListResponseImplToJson(this);
  }
}

abstract class _GameSessionListResponse implements GameSessionListResponse {
  const factory _GameSessionListResponse({
    required final List<GameSession> sessions,
    required final int totalCount,
    required final int page,
    required final int pageSize,
  }) = _$GameSessionListResponseImpl;

  factory _GameSessionListResponse.fromJson(Map<String, dynamic> json) =
      _$GameSessionListResponseImpl.fromJson;

  @override
  List<GameSession> get sessions;
  @override
  int get totalCount;
  @override
  int get page;
  @override
  int get pageSize;

  /// Create a copy of GameSessionListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameSessionListResponseImplCopyWith<_$GameSessionListResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}
