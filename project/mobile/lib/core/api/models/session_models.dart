import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_models.freezed.dart';
part 'session_models.g.dart';

/// GameSessionStatus enum matching the backend exactly
/// public enum GameSessionStatus { WaitingForPlayers = 0, InProgress = 1, Completed = 2, Cancelled = 3 }
enum GameSessionStatus {
  @JsonValue(0)
  waitingForPlayers,
  @JsonValue(1)
  inProgress,
  @JsonValue(2)
  completed,
  @JsonValue(3)
  cancelled,
}

/// GameSession matching the backend C# record exactly
/// public readonly record struct GameSessionResponse(
///     string Id,
///     string Code,
///     string Name,
///     int MaxPlayers,
///     int CurrentPlayerCount,
///     GameSessionStatus Status,
///     string[] Players,
///     string CreatedByUserId,
///     string? CreatedByUserName,
///     DateTime CreatedAt,
///     DateTime? StartedAt,
///     DateTime? EndedAt,
///     bool CanJoin,
///     bool IsFull);
@freezed
class GameSession with _$GameSession {
  const factory GameSession({
    required String id,
    required String code,
    required String name,
    required int maxPlayers,
    required int currentPlayerCount,
    required GameSessionStatus status,
    required List<String> players,
    required String createdByUserId,
    String? createdByUserName,
    required DateTime createdAt,
    DateTime? startedAt,
    DateTime? endedAt,
    required bool canJoin,
    required bool isFull,
  }) = _GameSession;

  factory GameSession.fromJson(Map<String, dynamic> json) => _$GameSessionFromJson(json);
}

/// Extension for additional computed properties and methods
extension GameSessionExtension on GameSession {
  /// Helper getters for compatibility
  String get hostId => createdByUserId;
  String? get hostName => createdByUserName;
  bool get canStart => currentPlayerCount >= 2 && status == GameSessionStatus.waitingForPlayers;
  String get shareableLink => 'checkgames://join/$code';
  
  /// Check if current user is the host
  bool isHostUser(String? currentUserId) => currentUserId != null && currentUserId == createdByUserId;
  
  /// Check if current user is in the session
  bool hasPlayer(String playerName) => players.contains(playerName);
}

/// CreateGameSessionRequest matching backend C# record exactly
/// public readonly record struct CreateGameSessionRequest(string? Description, int MaxPlayersLimit);
@freezed
class CreateSessionRequest with _$CreateSessionRequest {
  const factory CreateSessionRequest({
    String? description,
    required int maxPlayersLimit,
  }) = _CreateSessionRequest;

  factory CreateSessionRequest.fromJson(Map<String, dynamic> json) => _$CreateSessionRequestFromJson(json);
}

/// CreateSessionResponse matching backend C# record exactly
/// public readonly record struct CreateSessionResponse(GameSessionResponse Session, string ShareableLink);
@freezed
class CreateSessionResponse with _$CreateSessionResponse {
  const factory CreateSessionResponse({
    required GameSession session,
    required String shareableLink,
  }) = _CreateSessionResponse;

  factory CreateSessionResponse.fromJson(Map<String, dynamic> json) => _$CreateSessionResponseFromJson(json);
}

/// JoinGameSessionRequest matching backend C# record exactly
/// public readonly record struct JoinGameSessionRequest(string? PlayerName);
@freezed
class JoinSessionRequest with _$JoinSessionRequest {
  const factory JoinSessionRequest({
    String? playerName,
  }) = _JoinSessionRequest;

  factory JoinSessionRequest.fromJson(Map<String, dynamic> json) => _$JoinSessionRequestFromJson(json);
}

/// JoinSessionResponse matching backend C# record exactly
/// public readonly record struct JoinSessionResponse(string SessionId, string AssignedPlayerName, GameSessionResponse Session);
@freezed
class JoinSessionResponse with _$JoinSessionResponse {
  const factory JoinSessionResponse({
    required String sessionId,
    required String assignedPlayerName,
    required GameSession session,
  }) = _JoinSessionResponse;

  factory JoinSessionResponse.fromJson(Map<String, dynamic> json) => _$JoinSessionResponseFromJson(json);
}

/// LeaveGameSessionRequest matching backend C# record exactly  
/// public readonly record struct LeaveGameSessionRequest(string SessionId);
@freezed
class LeaveSessionRequest with _$LeaveSessionRequest {
  const factory LeaveSessionRequest({
    required String sessionId,
  }) = _LeaveSessionRequest;

  factory LeaveSessionRequest.fromJson(Map<String, dynamic> json) => _$LeaveSessionRequestFromJson(json);
}

/// GameSessionListResponse matching backend C# record exactly
/// public readonly record struct GameSessionListResponse(GameSessionResponse[] Sessions, int TotalCount, int Page, int PageSize);
@freezed
class GameSessionListResponse with _$GameSessionListResponse {
  const factory GameSessionListResponse({
    required List<GameSession> sessions,
    required int totalCount,
    required int page,
    required int pageSize,
  }) = _GameSessionListResponse;

  factory GameSessionListResponse.fromJson(Map<String, dynamic> json) => _$GameSessionListResponseFromJson(json);
}