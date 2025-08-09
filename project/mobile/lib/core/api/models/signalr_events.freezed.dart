// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'signalr_events.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PlayerJoinedEvent _$PlayerJoinedEventFromJson(Map<String, dynamic> json) {
  return _PlayerJoinedEvent.fromJson(json);
}

/// @nodoc
mixin _$PlayerJoinedEvent {
  String get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String get sessionId => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this PlayerJoinedEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlayerJoinedEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlayerJoinedEventCopyWith<PlayerJoinedEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayerJoinedEventCopyWith<$Res> {
  factory $PlayerJoinedEventCopyWith(
    PlayerJoinedEvent value,
    $Res Function(PlayerJoinedEvent) then,
  ) = _$PlayerJoinedEventCopyWithImpl<$Res, PlayerJoinedEvent>;
  @useResult
  $Res call({
    String userId,
    String userName,
    String sessionId,
    DateTime timestamp,
  });
}

/// @nodoc
class _$PlayerJoinedEventCopyWithImpl<$Res, $Val extends PlayerJoinedEvent>
    implements $PlayerJoinedEventCopyWith<$Res> {
  _$PlayerJoinedEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlayerJoinedEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? sessionId = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlayerJoinedEventImplCopyWith<$Res>
    implements $PlayerJoinedEventCopyWith<$Res> {
  factory _$$PlayerJoinedEventImplCopyWith(
    _$PlayerJoinedEventImpl value,
    $Res Function(_$PlayerJoinedEventImpl) then,
  ) = __$$PlayerJoinedEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String userName,
    String sessionId,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$PlayerJoinedEventImplCopyWithImpl<$Res>
    extends _$PlayerJoinedEventCopyWithImpl<$Res, _$PlayerJoinedEventImpl>
    implements _$$PlayerJoinedEventImplCopyWith<$Res> {
  __$$PlayerJoinedEventImplCopyWithImpl(
    _$PlayerJoinedEventImpl _value,
    $Res Function(_$PlayerJoinedEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlayerJoinedEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? sessionId = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$PlayerJoinedEventImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlayerJoinedEventImpl implements _PlayerJoinedEvent {
  const _$PlayerJoinedEventImpl({
    required this.userId,
    required this.userName,
    required this.sessionId,
    required this.timestamp,
  });

  factory _$PlayerJoinedEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlayerJoinedEventImplFromJson(json);

  @override
  final String userId;
  @override
  final String userName;
  @override
  final String sessionId;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'PlayerJoinedEvent(userId: $userId, userName: $userName, sessionId: $sessionId, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayerJoinedEventImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, userName, sessionId, timestamp);

  /// Create a copy of PlayerJoinedEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayerJoinedEventImplCopyWith<_$PlayerJoinedEventImpl> get copyWith =>
      __$$PlayerJoinedEventImplCopyWithImpl<_$PlayerJoinedEventImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PlayerJoinedEventImplToJson(this);
  }
}

abstract class _PlayerJoinedEvent implements PlayerJoinedEvent {
  const factory _PlayerJoinedEvent({
    required final String userId,
    required final String userName,
    required final String sessionId,
    required final DateTime timestamp,
  }) = _$PlayerJoinedEventImpl;

  factory _PlayerJoinedEvent.fromJson(Map<String, dynamic> json) =
      _$PlayerJoinedEventImpl.fromJson;

  @override
  String get userId;
  @override
  String get userName;
  @override
  String get sessionId;
  @override
  DateTime get timestamp;

  /// Create a copy of PlayerJoinedEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlayerJoinedEventImplCopyWith<_$PlayerJoinedEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlayerLeftEvent _$PlayerLeftEventFromJson(Map<String, dynamic> json) {
  return _PlayerLeftEvent.fromJson(json);
}

/// @nodoc
mixin _$PlayerLeftEvent {
  String get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String get sessionId => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this PlayerLeftEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlayerLeftEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlayerLeftEventCopyWith<PlayerLeftEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayerLeftEventCopyWith<$Res> {
  factory $PlayerLeftEventCopyWith(
    PlayerLeftEvent value,
    $Res Function(PlayerLeftEvent) then,
  ) = _$PlayerLeftEventCopyWithImpl<$Res, PlayerLeftEvent>;
  @useResult
  $Res call({
    String userId,
    String userName,
    String sessionId,
    DateTime timestamp,
  });
}

/// @nodoc
class _$PlayerLeftEventCopyWithImpl<$Res, $Val extends PlayerLeftEvent>
    implements $PlayerLeftEventCopyWith<$Res> {
  _$PlayerLeftEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlayerLeftEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? sessionId = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlayerLeftEventImplCopyWith<$Res>
    implements $PlayerLeftEventCopyWith<$Res> {
  factory _$$PlayerLeftEventImplCopyWith(
    _$PlayerLeftEventImpl value,
    $Res Function(_$PlayerLeftEventImpl) then,
  ) = __$$PlayerLeftEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String userName,
    String sessionId,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$PlayerLeftEventImplCopyWithImpl<$Res>
    extends _$PlayerLeftEventCopyWithImpl<$Res, _$PlayerLeftEventImpl>
    implements _$$PlayerLeftEventImplCopyWith<$Res> {
  __$$PlayerLeftEventImplCopyWithImpl(
    _$PlayerLeftEventImpl _value,
    $Res Function(_$PlayerLeftEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlayerLeftEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? sessionId = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$PlayerLeftEventImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlayerLeftEventImpl implements _PlayerLeftEvent {
  const _$PlayerLeftEventImpl({
    required this.userId,
    required this.userName,
    required this.sessionId,
    required this.timestamp,
  });

  factory _$PlayerLeftEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlayerLeftEventImplFromJson(json);

  @override
  final String userId;
  @override
  final String userName;
  @override
  final String sessionId;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'PlayerLeftEvent(userId: $userId, userName: $userName, sessionId: $sessionId, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayerLeftEventImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, userName, sessionId, timestamp);

  /// Create a copy of PlayerLeftEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayerLeftEventImplCopyWith<_$PlayerLeftEventImpl> get copyWith =>
      __$$PlayerLeftEventImplCopyWithImpl<_$PlayerLeftEventImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PlayerLeftEventImplToJson(this);
  }
}

abstract class _PlayerLeftEvent implements PlayerLeftEvent {
  const factory _PlayerLeftEvent({
    required final String userId,
    required final String userName,
    required final String sessionId,
    required final DateTime timestamp,
  }) = _$PlayerLeftEventImpl;

  factory _PlayerLeftEvent.fromJson(Map<String, dynamic> json) =
      _$PlayerLeftEventImpl.fromJson;

  @override
  String get userId;
  @override
  String get userName;
  @override
  String get sessionId;
  @override
  DateTime get timestamp;

  /// Create a copy of PlayerLeftEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlayerLeftEventImplCopyWith<_$PlayerLeftEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CardPlayedEvent _$CardPlayedEventFromJson(Map<String, dynamic> json) {
  return _CardPlayedEvent.fromJson(json);
}

/// @nodoc
mixin _$CardPlayedEvent {
  String get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String get sessionId => throw _privateConstructorUsedError;
  Map<String, dynamic> get card =>
      throw _privateConstructorUsedError; // Flexible card data structure
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this CardPlayedEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CardPlayedEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CardPlayedEventCopyWith<CardPlayedEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CardPlayedEventCopyWith<$Res> {
  factory $CardPlayedEventCopyWith(
    CardPlayedEvent value,
    $Res Function(CardPlayedEvent) then,
  ) = _$CardPlayedEventCopyWithImpl<$Res, CardPlayedEvent>;
  @useResult
  $Res call({
    String userId,
    String userName,
    String sessionId,
    Map<String, dynamic> card,
    DateTime timestamp,
  });
}

/// @nodoc
class _$CardPlayedEventCopyWithImpl<$Res, $Val extends CardPlayedEvent>
    implements $CardPlayedEventCopyWith<$Res> {
  _$CardPlayedEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CardPlayedEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? sessionId = null,
    Object? card = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            card: null == card
                ? _value.card
                : card // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CardPlayedEventImplCopyWith<$Res>
    implements $CardPlayedEventCopyWith<$Res> {
  factory _$$CardPlayedEventImplCopyWith(
    _$CardPlayedEventImpl value,
    $Res Function(_$CardPlayedEventImpl) then,
  ) = __$$CardPlayedEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String userName,
    String sessionId,
    Map<String, dynamic> card,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$CardPlayedEventImplCopyWithImpl<$Res>
    extends _$CardPlayedEventCopyWithImpl<$Res, _$CardPlayedEventImpl>
    implements _$$CardPlayedEventImplCopyWith<$Res> {
  __$$CardPlayedEventImplCopyWithImpl(
    _$CardPlayedEventImpl _value,
    $Res Function(_$CardPlayedEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CardPlayedEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? sessionId = null,
    Object? card = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$CardPlayedEventImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        card: null == card
            ? _value._card
            : card // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CardPlayedEventImpl implements _CardPlayedEvent {
  const _$CardPlayedEventImpl({
    required this.userId,
    required this.userName,
    required this.sessionId,
    required final Map<String, dynamic> card,
    required this.timestamp,
  }) : _card = card;

  factory _$CardPlayedEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$CardPlayedEventImplFromJson(json);

  @override
  final String userId;
  @override
  final String userName;
  @override
  final String sessionId;
  final Map<String, dynamic> _card;
  @override
  Map<String, dynamic> get card {
    if (_card is EqualUnmodifiableMapView) return _card;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_card);
  }

  // Flexible card data structure
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'CardPlayedEvent(userId: $userId, userName: $userName, sessionId: $sessionId, card: $card, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CardPlayedEventImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            const DeepCollectionEquality().equals(other._card, _card) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    userName,
    sessionId,
    const DeepCollectionEquality().hash(_card),
    timestamp,
  );

  /// Create a copy of CardPlayedEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CardPlayedEventImplCopyWith<_$CardPlayedEventImpl> get copyWith =>
      __$$CardPlayedEventImplCopyWithImpl<_$CardPlayedEventImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CardPlayedEventImplToJson(this);
  }
}

abstract class _CardPlayedEvent implements CardPlayedEvent {
  const factory _CardPlayedEvent({
    required final String userId,
    required final String userName,
    required final String sessionId,
    required final Map<String, dynamic> card,
    required final DateTime timestamp,
  }) = _$CardPlayedEventImpl;

  factory _CardPlayedEvent.fromJson(Map<String, dynamic> json) =
      _$CardPlayedEventImpl.fromJson;

  @override
  String get userId;
  @override
  String get userName;
  @override
  String get sessionId;
  @override
  Map<String, dynamic> get card; // Flexible card data structure
  @override
  DateTime get timestamp;

  /// Create a copy of CardPlayedEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CardPlayedEventImplCopyWith<_$CardPlayedEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CardDrawnEvent _$CardDrawnEventFromJson(Map<String, dynamic> json) {
  return _CardDrawnEvent.fromJson(json);
}

/// @nodoc
mixin _$CardDrawnEvent {
  String get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String get sessionId => throw _privateConstructorUsedError;
  int get cardCount => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this CardDrawnEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CardDrawnEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CardDrawnEventCopyWith<CardDrawnEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CardDrawnEventCopyWith<$Res> {
  factory $CardDrawnEventCopyWith(
    CardDrawnEvent value,
    $Res Function(CardDrawnEvent) then,
  ) = _$CardDrawnEventCopyWithImpl<$Res, CardDrawnEvent>;
  @useResult
  $Res call({
    String userId,
    String userName,
    String sessionId,
    int cardCount,
    DateTime timestamp,
  });
}

/// @nodoc
class _$CardDrawnEventCopyWithImpl<$Res, $Val extends CardDrawnEvent>
    implements $CardDrawnEventCopyWith<$Res> {
  _$CardDrawnEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CardDrawnEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? sessionId = null,
    Object? cardCount = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            cardCount: null == cardCount
                ? _value.cardCount
                : cardCount // ignore: cast_nullable_to_non_nullable
                      as int,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CardDrawnEventImplCopyWith<$Res>
    implements $CardDrawnEventCopyWith<$Res> {
  factory _$$CardDrawnEventImplCopyWith(
    _$CardDrawnEventImpl value,
    $Res Function(_$CardDrawnEventImpl) then,
  ) = __$$CardDrawnEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String userName,
    String sessionId,
    int cardCount,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$CardDrawnEventImplCopyWithImpl<$Res>
    extends _$CardDrawnEventCopyWithImpl<$Res, _$CardDrawnEventImpl>
    implements _$$CardDrawnEventImplCopyWith<$Res> {
  __$$CardDrawnEventImplCopyWithImpl(
    _$CardDrawnEventImpl _value,
    $Res Function(_$CardDrawnEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CardDrawnEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? sessionId = null,
    Object? cardCount = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$CardDrawnEventImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        cardCount: null == cardCount
            ? _value.cardCount
            : cardCount // ignore: cast_nullable_to_non_nullable
                  as int,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CardDrawnEventImpl implements _CardDrawnEvent {
  const _$CardDrawnEventImpl({
    required this.userId,
    required this.userName,
    required this.sessionId,
    required this.cardCount,
    required this.timestamp,
  });

  factory _$CardDrawnEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$CardDrawnEventImplFromJson(json);

  @override
  final String userId;
  @override
  final String userName;
  @override
  final String sessionId;
  @override
  final int cardCount;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'CardDrawnEvent(userId: $userId, userName: $userName, sessionId: $sessionId, cardCount: $cardCount, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CardDrawnEventImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.cardCount, cardCount) ||
                other.cardCount == cardCount) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    userName,
    sessionId,
    cardCount,
    timestamp,
  );

  /// Create a copy of CardDrawnEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CardDrawnEventImplCopyWith<_$CardDrawnEventImpl> get copyWith =>
      __$$CardDrawnEventImplCopyWithImpl<_$CardDrawnEventImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CardDrawnEventImplToJson(this);
  }
}

abstract class _CardDrawnEvent implements CardDrawnEvent {
  const factory _CardDrawnEvent({
    required final String userId,
    required final String userName,
    required final String sessionId,
    required final int cardCount,
    required final DateTime timestamp,
  }) = _$CardDrawnEventImpl;

  factory _CardDrawnEvent.fromJson(Map<String, dynamic> json) =
      _$CardDrawnEventImpl.fromJson;

  @override
  String get userId;
  @override
  String get userName;
  @override
  String get sessionId;
  @override
  int get cardCount;
  @override
  DateTime get timestamp;

  /// Create a copy of CardDrawnEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CardDrawnEventImplCopyWith<_$CardDrawnEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SuitChangedEvent _$SuitChangedEventFromJson(Map<String, dynamic> json) {
  return _SuitChangedEvent.fromJson(json);
}

/// @nodoc
mixin _$SuitChangedEvent {
  String get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String get sessionId => throw _privateConstructorUsedError;
  String get newSuit => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this SuitChangedEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SuitChangedEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SuitChangedEventCopyWith<SuitChangedEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SuitChangedEventCopyWith<$Res> {
  factory $SuitChangedEventCopyWith(
    SuitChangedEvent value,
    $Res Function(SuitChangedEvent) then,
  ) = _$SuitChangedEventCopyWithImpl<$Res, SuitChangedEvent>;
  @useResult
  $Res call({
    String userId,
    String userName,
    String sessionId,
    String newSuit,
    DateTime timestamp,
  });
}

/// @nodoc
class _$SuitChangedEventCopyWithImpl<$Res, $Val extends SuitChangedEvent>
    implements $SuitChangedEventCopyWith<$Res> {
  _$SuitChangedEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SuitChangedEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? sessionId = null,
    Object? newSuit = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            newSuit: null == newSuit
                ? _value.newSuit
                : newSuit // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SuitChangedEventImplCopyWith<$Res>
    implements $SuitChangedEventCopyWith<$Res> {
  factory _$$SuitChangedEventImplCopyWith(
    _$SuitChangedEventImpl value,
    $Res Function(_$SuitChangedEventImpl) then,
  ) = __$$SuitChangedEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String userName,
    String sessionId,
    String newSuit,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$SuitChangedEventImplCopyWithImpl<$Res>
    extends _$SuitChangedEventCopyWithImpl<$Res, _$SuitChangedEventImpl>
    implements _$$SuitChangedEventImplCopyWith<$Res> {
  __$$SuitChangedEventImplCopyWithImpl(
    _$SuitChangedEventImpl _value,
    $Res Function(_$SuitChangedEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SuitChangedEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? sessionId = null,
    Object? newSuit = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$SuitChangedEventImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        newSuit: null == newSuit
            ? _value.newSuit
            : newSuit // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SuitChangedEventImpl implements _SuitChangedEvent {
  const _$SuitChangedEventImpl({
    required this.userId,
    required this.userName,
    required this.sessionId,
    required this.newSuit,
    required this.timestamp,
  });

  factory _$SuitChangedEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$SuitChangedEventImplFromJson(json);

  @override
  final String userId;
  @override
  final String userName;
  @override
  final String sessionId;
  @override
  final String newSuit;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'SuitChangedEvent(userId: $userId, userName: $userName, sessionId: $sessionId, newSuit: $newSuit, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SuitChangedEventImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.newSuit, newSuit) || other.newSuit == newSuit) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, userName, sessionId, newSuit, timestamp);

  /// Create a copy of SuitChangedEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SuitChangedEventImplCopyWith<_$SuitChangedEventImpl> get copyWith =>
      __$$SuitChangedEventImplCopyWithImpl<_$SuitChangedEventImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SuitChangedEventImplToJson(this);
  }
}

abstract class _SuitChangedEvent implements SuitChangedEvent {
  const factory _SuitChangedEvent({
    required final String userId,
    required final String userName,
    required final String sessionId,
    required final String newSuit,
    required final DateTime timestamp,
  }) = _$SuitChangedEventImpl;

  factory _SuitChangedEvent.fromJson(Map<String, dynamic> json) =
      _$SuitChangedEventImpl.fromJson;

  @override
  String get userId;
  @override
  String get userName;
  @override
  String get sessionId;
  @override
  String get newSuit;
  @override
  DateTime get timestamp;

  /// Create a copy of SuitChangedEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SuitChangedEventImplCopyWith<_$SuitChangedEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GameStateUpdatedEvent _$GameStateUpdatedEventFromJson(
  Map<String, dynamic> json,
) {
  return _GameStateUpdatedEvent.fromJson(json);
}

/// @nodoc
mixin _$GameStateUpdatedEvent {
  String get sessionId => throw _privateConstructorUsedError;
  Map<String, dynamic> get gameState =>
      throw _privateConstructorUsedError; // Flexible game state structure
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this GameStateUpdatedEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameStateUpdatedEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameStateUpdatedEventCopyWith<GameStateUpdatedEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameStateUpdatedEventCopyWith<$Res> {
  factory $GameStateUpdatedEventCopyWith(
    GameStateUpdatedEvent value,
    $Res Function(GameStateUpdatedEvent) then,
  ) = _$GameStateUpdatedEventCopyWithImpl<$Res, GameStateUpdatedEvent>;
  @useResult
  $Res call({
    String sessionId,
    Map<String, dynamic> gameState,
    DateTime timestamp,
  });
}

/// @nodoc
class _$GameStateUpdatedEventCopyWithImpl<
  $Res,
  $Val extends GameStateUpdatedEvent
>
    implements $GameStateUpdatedEventCopyWith<$Res> {
  _$GameStateUpdatedEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameStateUpdatedEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? gameState = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            gameState: null == gameState
                ? _value.gameState
                : gameState // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameStateUpdatedEventImplCopyWith<$Res>
    implements $GameStateUpdatedEventCopyWith<$Res> {
  factory _$$GameStateUpdatedEventImplCopyWith(
    _$GameStateUpdatedEventImpl value,
    $Res Function(_$GameStateUpdatedEventImpl) then,
  ) = __$$GameStateUpdatedEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String sessionId,
    Map<String, dynamic> gameState,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$GameStateUpdatedEventImplCopyWithImpl<$Res>
    extends
        _$GameStateUpdatedEventCopyWithImpl<$Res, _$GameStateUpdatedEventImpl>
    implements _$$GameStateUpdatedEventImplCopyWith<$Res> {
  __$$GameStateUpdatedEventImplCopyWithImpl(
    _$GameStateUpdatedEventImpl _value,
    $Res Function(_$GameStateUpdatedEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameStateUpdatedEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? gameState = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$GameStateUpdatedEventImpl(
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        gameState: null == gameState
            ? _value._gameState
            : gameState // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameStateUpdatedEventImpl implements _GameStateUpdatedEvent {
  const _$GameStateUpdatedEventImpl({
    required this.sessionId,
    required final Map<String, dynamic> gameState,
    required this.timestamp,
  }) : _gameState = gameState;

  factory _$GameStateUpdatedEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameStateUpdatedEventImplFromJson(json);

  @override
  final String sessionId;
  final Map<String, dynamic> _gameState;
  @override
  Map<String, dynamic> get gameState {
    if (_gameState is EqualUnmodifiableMapView) return _gameState;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_gameState);
  }

  // Flexible game state structure
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'GameStateUpdatedEvent(sessionId: $sessionId, gameState: $gameState, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameStateUpdatedEventImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            const DeepCollectionEquality().equals(
              other._gameState,
              _gameState,
            ) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    sessionId,
    const DeepCollectionEquality().hash(_gameState),
    timestamp,
  );

  /// Create a copy of GameStateUpdatedEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameStateUpdatedEventImplCopyWith<_$GameStateUpdatedEventImpl>
  get copyWith =>
      __$$GameStateUpdatedEventImplCopyWithImpl<_$GameStateUpdatedEventImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GameStateUpdatedEventImplToJson(this);
  }
}

abstract class _GameStateUpdatedEvent implements GameStateUpdatedEvent {
  const factory _GameStateUpdatedEvent({
    required final String sessionId,
    required final Map<String, dynamic> gameState,
    required final DateTime timestamp,
  }) = _$GameStateUpdatedEventImpl;

  factory _GameStateUpdatedEvent.fromJson(Map<String, dynamic> json) =
      _$GameStateUpdatedEventImpl.fromJson;

  @override
  String get sessionId;
  @override
  Map<String, dynamic> get gameState; // Flexible game state structure
  @override
  DateTime get timestamp;

  /// Create a copy of GameStateUpdatedEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameStateUpdatedEventImplCopyWith<_$GameStateUpdatedEventImpl>
  get copyWith => throw _privateConstructorUsedError;
}

GameStartedEvent _$GameStartedEventFromJson(Map<String, dynamic> json) {
  return _GameStartedEvent.fromJson(json);
}

/// @nodoc
mixin _$GameStartedEvent {
  String get sessionId => throw _privateConstructorUsedError;
  List<String> get playerIds => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this GameStartedEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameStartedEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameStartedEventCopyWith<GameStartedEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameStartedEventCopyWith<$Res> {
  factory $GameStartedEventCopyWith(
    GameStartedEvent value,
    $Res Function(GameStartedEvent) then,
  ) = _$GameStartedEventCopyWithImpl<$Res, GameStartedEvent>;
  @useResult
  $Res call({String sessionId, List<String> playerIds, DateTime timestamp});
}

/// @nodoc
class _$GameStartedEventCopyWithImpl<$Res, $Val extends GameStartedEvent>
    implements $GameStartedEventCopyWith<$Res> {
  _$GameStartedEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameStartedEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? playerIds = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            playerIds: null == playerIds
                ? _value.playerIds
                : playerIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameStartedEventImplCopyWith<$Res>
    implements $GameStartedEventCopyWith<$Res> {
  factory _$$GameStartedEventImplCopyWith(
    _$GameStartedEventImpl value,
    $Res Function(_$GameStartedEventImpl) then,
  ) = __$$GameStartedEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String sessionId, List<String> playerIds, DateTime timestamp});
}

/// @nodoc
class __$$GameStartedEventImplCopyWithImpl<$Res>
    extends _$GameStartedEventCopyWithImpl<$Res, _$GameStartedEventImpl>
    implements _$$GameStartedEventImplCopyWith<$Res> {
  __$$GameStartedEventImplCopyWithImpl(
    _$GameStartedEventImpl _value,
    $Res Function(_$GameStartedEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameStartedEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? playerIds = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$GameStartedEventImpl(
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        playerIds: null == playerIds
            ? _value._playerIds
            : playerIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameStartedEventImpl implements _GameStartedEvent {
  const _$GameStartedEventImpl({
    required this.sessionId,
    required final List<String> playerIds,
    required this.timestamp,
  }) : _playerIds = playerIds;

  factory _$GameStartedEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameStartedEventImplFromJson(json);

  @override
  final String sessionId;
  final List<String> _playerIds;
  @override
  List<String> get playerIds {
    if (_playerIds is EqualUnmodifiableListView) return _playerIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_playerIds);
  }

  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'GameStartedEvent(sessionId: $sessionId, playerIds: $playerIds, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameStartedEventImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            const DeepCollectionEquality().equals(
              other._playerIds,
              _playerIds,
            ) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    sessionId,
    const DeepCollectionEquality().hash(_playerIds),
    timestamp,
  );

  /// Create a copy of GameStartedEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameStartedEventImplCopyWith<_$GameStartedEventImpl> get copyWith =>
      __$$GameStartedEventImplCopyWithImpl<_$GameStartedEventImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GameStartedEventImplToJson(this);
  }
}

abstract class _GameStartedEvent implements GameStartedEvent {
  const factory _GameStartedEvent({
    required final String sessionId,
    required final List<String> playerIds,
    required final DateTime timestamp,
  }) = _$GameStartedEventImpl;

  factory _GameStartedEvent.fromJson(Map<String, dynamic> json) =
      _$GameStartedEventImpl.fromJson;

  @override
  String get sessionId;
  @override
  List<String> get playerIds;
  @override
  DateTime get timestamp;

  /// Create a copy of GameStartedEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameStartedEventImplCopyWith<_$GameStartedEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GameEndedEvent _$GameEndedEventFromJson(Map<String, dynamic> json) {
  return _GameEndedEvent.fromJson(json);
}

/// @nodoc
mixin _$GameEndedEvent {
  String get sessionId => throw _privateConstructorUsedError;
  String get winnerId => throw _privateConstructorUsedError;
  List<String> get playerRanking => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this GameEndedEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameEndedEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameEndedEventCopyWith<GameEndedEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameEndedEventCopyWith<$Res> {
  factory $GameEndedEventCopyWith(
    GameEndedEvent value,
    $Res Function(GameEndedEvent) then,
  ) = _$GameEndedEventCopyWithImpl<$Res, GameEndedEvent>;
  @useResult
  $Res call({
    String sessionId,
    String winnerId,
    List<String> playerRanking,
    DateTime timestamp,
  });
}

/// @nodoc
class _$GameEndedEventCopyWithImpl<$Res, $Val extends GameEndedEvent>
    implements $GameEndedEventCopyWith<$Res> {
  _$GameEndedEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameEndedEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? winnerId = null,
    Object? playerRanking = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            winnerId: null == winnerId
                ? _value.winnerId
                : winnerId // ignore: cast_nullable_to_non_nullable
                      as String,
            playerRanking: null == playerRanking
                ? _value.playerRanking
                : playerRanking // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameEndedEventImplCopyWith<$Res>
    implements $GameEndedEventCopyWith<$Res> {
  factory _$$GameEndedEventImplCopyWith(
    _$GameEndedEventImpl value,
    $Res Function(_$GameEndedEventImpl) then,
  ) = __$$GameEndedEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String sessionId,
    String winnerId,
    List<String> playerRanking,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$GameEndedEventImplCopyWithImpl<$Res>
    extends _$GameEndedEventCopyWithImpl<$Res, _$GameEndedEventImpl>
    implements _$$GameEndedEventImplCopyWith<$Res> {
  __$$GameEndedEventImplCopyWithImpl(
    _$GameEndedEventImpl _value,
    $Res Function(_$GameEndedEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameEndedEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? winnerId = null,
    Object? playerRanking = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$GameEndedEventImpl(
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        winnerId: null == winnerId
            ? _value.winnerId
            : winnerId // ignore: cast_nullable_to_non_nullable
                  as String,
        playerRanking: null == playerRanking
            ? _value._playerRanking
            : playerRanking // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameEndedEventImpl implements _GameEndedEvent {
  const _$GameEndedEventImpl({
    required this.sessionId,
    required this.winnerId,
    required final List<String> playerRanking,
    required this.timestamp,
  }) : _playerRanking = playerRanking;

  factory _$GameEndedEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameEndedEventImplFromJson(json);

  @override
  final String sessionId;
  @override
  final String winnerId;
  final List<String> _playerRanking;
  @override
  List<String> get playerRanking {
    if (_playerRanking is EqualUnmodifiableListView) return _playerRanking;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_playerRanking);
  }

  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'GameEndedEvent(sessionId: $sessionId, winnerId: $winnerId, playerRanking: $playerRanking, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameEndedEventImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.winnerId, winnerId) ||
                other.winnerId == winnerId) &&
            const DeepCollectionEquality().equals(
              other._playerRanking,
              _playerRanking,
            ) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    sessionId,
    winnerId,
    const DeepCollectionEquality().hash(_playerRanking),
    timestamp,
  );

  /// Create a copy of GameEndedEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameEndedEventImplCopyWith<_$GameEndedEventImpl> get copyWith =>
      __$$GameEndedEventImplCopyWithImpl<_$GameEndedEventImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GameEndedEventImplToJson(this);
  }
}

abstract class _GameEndedEvent implements GameEndedEvent {
  const factory _GameEndedEvent({
    required final String sessionId,
    required final String winnerId,
    required final List<String> playerRanking,
    required final DateTime timestamp,
  }) = _$GameEndedEventImpl;

  factory _GameEndedEvent.fromJson(Map<String, dynamic> json) =
      _$GameEndedEventImpl.fromJson;

  @override
  String get sessionId;
  @override
  String get winnerId;
  @override
  List<String> get playerRanking;
  @override
  DateTime get timestamp;

  /// Create a copy of GameEndedEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameEndedEventImplCopyWith<_$GameEndedEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TurnChangedEvent _$TurnChangedEventFromJson(Map<String, dynamic> json) {
  return _TurnChangedEvent.fromJson(json);
}

/// @nodoc
mixin _$TurnChangedEvent {
  String get sessionId => throw _privateConstructorUsedError;
  String get currentPlayerId => throw _privateConstructorUsedError;
  String get nextPlayerId => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this TurnChangedEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TurnChangedEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TurnChangedEventCopyWith<TurnChangedEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TurnChangedEventCopyWith<$Res> {
  factory $TurnChangedEventCopyWith(
    TurnChangedEvent value,
    $Res Function(TurnChangedEvent) then,
  ) = _$TurnChangedEventCopyWithImpl<$Res, TurnChangedEvent>;
  @useResult
  $Res call({
    String sessionId,
    String currentPlayerId,
    String nextPlayerId,
    DateTime timestamp,
  });
}

/// @nodoc
class _$TurnChangedEventCopyWithImpl<$Res, $Val extends TurnChangedEvent>
    implements $TurnChangedEventCopyWith<$Res> {
  _$TurnChangedEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TurnChangedEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? currentPlayerId = null,
    Object? nextPlayerId = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            currentPlayerId: null == currentPlayerId
                ? _value.currentPlayerId
                : currentPlayerId // ignore: cast_nullable_to_non_nullable
                      as String,
            nextPlayerId: null == nextPlayerId
                ? _value.nextPlayerId
                : nextPlayerId // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TurnChangedEventImplCopyWith<$Res>
    implements $TurnChangedEventCopyWith<$Res> {
  factory _$$TurnChangedEventImplCopyWith(
    _$TurnChangedEventImpl value,
    $Res Function(_$TurnChangedEventImpl) then,
  ) = __$$TurnChangedEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String sessionId,
    String currentPlayerId,
    String nextPlayerId,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$TurnChangedEventImplCopyWithImpl<$Res>
    extends _$TurnChangedEventCopyWithImpl<$Res, _$TurnChangedEventImpl>
    implements _$$TurnChangedEventImplCopyWith<$Res> {
  __$$TurnChangedEventImplCopyWithImpl(
    _$TurnChangedEventImpl _value,
    $Res Function(_$TurnChangedEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TurnChangedEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? currentPlayerId = null,
    Object? nextPlayerId = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$TurnChangedEventImpl(
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        currentPlayerId: null == currentPlayerId
            ? _value.currentPlayerId
            : currentPlayerId // ignore: cast_nullable_to_non_nullable
                  as String,
        nextPlayerId: null == nextPlayerId
            ? _value.nextPlayerId
            : nextPlayerId // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TurnChangedEventImpl implements _TurnChangedEvent {
  const _$TurnChangedEventImpl({
    required this.sessionId,
    required this.currentPlayerId,
    required this.nextPlayerId,
    required this.timestamp,
  });

  factory _$TurnChangedEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$TurnChangedEventImplFromJson(json);

  @override
  final String sessionId;
  @override
  final String currentPlayerId;
  @override
  final String nextPlayerId;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'TurnChangedEvent(sessionId: $sessionId, currentPlayerId: $currentPlayerId, nextPlayerId: $nextPlayerId, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TurnChangedEventImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.currentPlayerId, currentPlayerId) ||
                other.currentPlayerId == currentPlayerId) &&
            (identical(other.nextPlayerId, nextPlayerId) ||
                other.nextPlayerId == nextPlayerId) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    sessionId,
    currentPlayerId,
    nextPlayerId,
    timestamp,
  );

  /// Create a copy of TurnChangedEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TurnChangedEventImplCopyWith<_$TurnChangedEventImpl> get copyWith =>
      __$$TurnChangedEventImplCopyWithImpl<_$TurnChangedEventImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TurnChangedEventImplToJson(this);
  }
}

abstract class _TurnChangedEvent implements TurnChangedEvent {
  const factory _TurnChangedEvent({
    required final String sessionId,
    required final String currentPlayerId,
    required final String nextPlayerId,
    required final DateTime timestamp,
  }) = _$TurnChangedEventImpl;

  factory _TurnChangedEvent.fromJson(Map<String, dynamic> json) =
      _$TurnChangedEventImpl.fromJson;

  @override
  String get sessionId;
  @override
  String get currentPlayerId;
  @override
  String get nextPlayerId;
  @override
  DateTime get timestamp;

  /// Create a copy of TurnChangedEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TurnChangedEventImplCopyWith<_$TurnChangedEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GameMessageEvent _$GameMessageEventFromJson(Map<String, dynamic> json) {
  return _GameMessageEvent.fromJson(json);
}

/// @nodoc
mixin _$GameMessageEvent {
  String get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String get sessionId => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this GameMessageEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameMessageEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameMessageEventCopyWith<GameMessageEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameMessageEventCopyWith<$Res> {
  factory $GameMessageEventCopyWith(
    GameMessageEvent value,
    $Res Function(GameMessageEvent) then,
  ) = _$GameMessageEventCopyWithImpl<$Res, GameMessageEvent>;
  @useResult
  $Res call({
    String userId,
    String userName,
    String sessionId,
    String message,
    DateTime timestamp,
  });
}

/// @nodoc
class _$GameMessageEventCopyWithImpl<$Res, $Val extends GameMessageEvent>
    implements $GameMessageEventCopyWith<$Res> {
  _$GameMessageEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameMessageEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? sessionId = null,
    Object? message = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameMessageEventImplCopyWith<$Res>
    implements $GameMessageEventCopyWith<$Res> {
  factory _$$GameMessageEventImplCopyWith(
    _$GameMessageEventImpl value,
    $Res Function(_$GameMessageEventImpl) then,
  ) = __$$GameMessageEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String userName,
    String sessionId,
    String message,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$GameMessageEventImplCopyWithImpl<$Res>
    extends _$GameMessageEventCopyWithImpl<$Res, _$GameMessageEventImpl>
    implements _$$GameMessageEventImplCopyWith<$Res> {
  __$$GameMessageEventImplCopyWithImpl(
    _$GameMessageEventImpl _value,
    $Res Function(_$GameMessageEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameMessageEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? sessionId = null,
    Object? message = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$GameMessageEventImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameMessageEventImpl implements _GameMessageEvent {
  const _$GameMessageEventImpl({
    required this.userId,
    required this.userName,
    required this.sessionId,
    required this.message,
    required this.timestamp,
  });

  factory _$GameMessageEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameMessageEventImplFromJson(json);

  @override
  final String userId;
  @override
  final String userName;
  @override
  final String sessionId;
  @override
  final String message;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'GameMessageEvent(userId: $userId, userName: $userName, sessionId: $sessionId, message: $message, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameMessageEventImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, userName, sessionId, message, timestamp);

  /// Create a copy of GameMessageEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameMessageEventImplCopyWith<_$GameMessageEventImpl> get copyWith =>
      __$$GameMessageEventImplCopyWithImpl<_$GameMessageEventImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GameMessageEventImplToJson(this);
  }
}

abstract class _GameMessageEvent implements GameMessageEvent {
  const factory _GameMessageEvent({
    required final String userId,
    required final String userName,
    required final String sessionId,
    required final String message,
    required final DateTime timestamp,
  }) = _$GameMessageEventImpl;

  factory _GameMessageEvent.fromJson(Map<String, dynamic> json) =
      _$GameMessageEventImpl.fromJson;

  @override
  String get userId;
  @override
  String get userName;
  @override
  String get sessionId;
  @override
  String get message;
  @override
  DateTime get timestamp;

  /// Create a copy of GameMessageEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameMessageEventImplCopyWith<_$GameMessageEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SignalRErrorEvent _$SignalRErrorEventFromJson(Map<String, dynamic> json) {
  return _SignalRErrorEvent.fromJson(json);
}

/// @nodoc
mixin _$SignalRErrorEvent {
  String get message => throw _privateConstructorUsedError;

  /// Serializes this SignalRErrorEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SignalRErrorEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SignalRErrorEventCopyWith<SignalRErrorEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SignalRErrorEventCopyWith<$Res> {
  factory $SignalRErrorEventCopyWith(
    SignalRErrorEvent value,
    $Res Function(SignalRErrorEvent) then,
  ) = _$SignalRErrorEventCopyWithImpl<$Res, SignalRErrorEvent>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$SignalRErrorEventCopyWithImpl<$Res, $Val extends SignalRErrorEvent>
    implements $SignalRErrorEventCopyWith<$Res> {
  _$SignalRErrorEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SignalRErrorEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _value.copyWith(
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SignalRErrorEventImplCopyWith<$Res>
    implements $SignalRErrorEventCopyWith<$Res> {
  factory _$$SignalRErrorEventImplCopyWith(
    _$SignalRErrorEventImpl value,
    $Res Function(_$SignalRErrorEventImpl) then,
  ) = __$$SignalRErrorEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$SignalRErrorEventImplCopyWithImpl<$Res>
    extends _$SignalRErrorEventCopyWithImpl<$Res, _$SignalRErrorEventImpl>
    implements _$$SignalRErrorEventImplCopyWith<$Res> {
  __$$SignalRErrorEventImplCopyWithImpl(
    _$SignalRErrorEventImpl _value,
    $Res Function(_$SignalRErrorEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SignalRErrorEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$SignalRErrorEventImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SignalRErrorEventImpl implements _SignalRErrorEvent {
  const _$SignalRErrorEventImpl({required this.message});

  factory _$SignalRErrorEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$SignalRErrorEventImplFromJson(json);

  @override
  final String message;

  @override
  String toString() {
    return 'SignalRErrorEvent(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SignalRErrorEventImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of SignalRErrorEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SignalRErrorEventImplCopyWith<_$SignalRErrorEventImpl> get copyWith =>
      __$$SignalRErrorEventImplCopyWithImpl<_$SignalRErrorEventImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SignalRErrorEventImplToJson(this);
  }
}

abstract class _SignalRErrorEvent implements SignalRErrorEvent {
  const factory _SignalRErrorEvent({required final String message}) =
      _$SignalRErrorEventImpl;

  factory _SignalRErrorEvent.fromJson(Map<String, dynamic> json) =
      _$SignalRErrorEventImpl.fromJson;

  @override
  String get message;

  /// Create a copy of SignalRErrorEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SignalRErrorEventImplCopyWith<_$SignalRErrorEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
