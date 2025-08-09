class GameSession {
  final String id;
  final String code;
  final String createdByUserId;
  final String createdByUserName;
  final String name;
  final SessionStatus status;
  final List<String> players;
  final DateTime createdAt;
  final int maxPlayers;

  const GameSession({
    required this.id,
    required this.code,
    required this.createdByUserId,
    required this.createdByUserName,
    required this.name,
    required this.status,
    required this.players,
    required this.createdAt,
    this.maxPlayers = 4,
  });

  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      id: json['id'] as String,
      code: json['code'] as String,
      createdByUserId: json['createdByUserId'] as String,
      createdByUserName: json['createdByUserName'] as String,
      name: json['name'] as String,
      status: SessionStatus.values.firstWhere(
        (e) => e.index == (json['status'] as int),
        orElse: () => SessionStatus.waiting,
      ),
      players: parsePlayers(json['players']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      maxPlayers: json['maxPlayers'] as int? ?? 4,
    );
  }

  static List<String> parsePlayers(List<dynamic> data) {
    List<String> result = [];
    for (var element in data) {
      result.add(element as String);
    }

    return result;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'createdByUserId': createdByUserId,
      'createdByUserName': createdByUserName,
      'name': name,
      'status': status.name,
      'players': players,
      'createdAt': createdAt.toIso8601String(),
      'maxPlayers': maxPlayers,
    };
  }

  GameSession copyWith({
    String? id,
    String? code,
    String? createdByUserId,
    String? createdByUserName,
    String? name,
    SessionStatus? status,
    List<String>? players,
    DateTime? createdAt,
    int? maxPlayers,
  }) {
    return GameSession(
      id: id ?? this.id,
      code: code ?? this.code,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdByUserName: createdByUserName ?? this.createdByUserName,
      name: name ?? this.name,
      status: status ?? this.status,
      players: players ?? this.players,
      createdAt: createdAt ?? this.createdAt,
      maxPlayers: maxPlayers ?? this.maxPlayers,
    );
  }

  // Helper getters for compatibility
  String get hostId => createdByUserId;
  String get hostName => createdByUserName;
  bool get isHost => players.any((p) => p == createdByUserName);
  bool get isFull => players.length >= maxPlayers;
  bool get canStart => players.length >= 2 && status == SessionStatus.waiting;
  String get shareableLink => 'checkgames://join/$code';
}

enum SessionStatus { waiting, inProgress, completed, cancelled }

class CreateSessionRequest {
  final String name;
  final int maxPlayers;

  const CreateSessionRequest({required this.name, this.maxPlayers = 4});

  Map<String, dynamic> toJson() {
    return {'name': name, 'maxPlayers': maxPlayers};
  }
}

class CreateSessionResponse {
  final GameSession session;
  final String shareableLink;

  const CreateSessionResponse({
    required this.session,
    required this.shareableLink,
  });

  factory CreateSessionResponse.fromJson(Map<String, dynamic> json) {
    var session = json['session'] as Map<String, dynamic>;
    var shareableLink = json['shareableLink'] as String;
    return CreateSessionResponse(
      session: GameSession.fromJson(session),
      shareableLink: shareableLink,
    );
  }
}

class JoinSessionRequest {
  final String sessionCode;
  final String? playerName;

  const JoinSessionRequest({required this.sessionCode, this.playerName});

  Map<String, dynamic> toJson() {
    return {
      'sessionCode': sessionCode,
      if (playerName != null) 'playerName': playerName,
    };
  }
}

/*

public readonly record struct JoinSessionResponse(
    string SessionId,
    string AssignedPlayerName,
    GameSessionResponse Session);

*/

class JoinSessionResponse {
  final String sessionId;
  final GameSession session;

  JoinSessionResponse({required this.sessionId, required this.session});

  factory JoinSessionResponse.fromJson(Map<String, dynamic> json) {
    return JoinSessionResponse(
      sessionId: json['sessionId'],
      session: GameSession.fromJson(json['session']),
    );
  }
}
