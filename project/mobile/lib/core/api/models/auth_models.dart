// Register Request Model
class RegisterRequest {
  final String userName;
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  const RegisterRequest({
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
    };
  }
}

// Login Request Model
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

// JWT Response Model
class JwtResponse {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  const JwtResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  factory JwtResponse.fromJson(Map<String, dynamic> json) {
    return JwtResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }
}

// User Profile Model
class UserProfile {
  final String id;
  final String userName;
  final String firstName;
  final String lastName;
  final String email;

  const UserProfile({
    required this.id,
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      userName: json['userName'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    };
  }

  String get displayName => '$firstName $lastName'.trim();
}

// API Response wrapper for error handling
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final Map<String, List<String>>? validationErrors;

  const ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.validationErrors,
  });

  factory ApiResponse.success(T data) {
    return ApiResponse(success: true, data: data);
  }

  factory ApiResponse.error(String error) {
    return ApiResponse(success: false, error: error);
  }

  factory ApiResponse.validationError(
    Map<String, List<String>> validationErrors,
  ) {
    return ApiResponse(success: false, validationErrors: validationErrors);
  }
}
