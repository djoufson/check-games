import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

/// Register Request Model
@freezed
class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    required String userName,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) = _RegisterRequest;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => _$RegisterRequestFromJson(json);
}

/// Login Request Model
@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String email,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
}

/// JWT Response Model
@freezed
class JwtResponse with _$JwtResponse {
  const factory JwtResponse({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) = _JwtResponse;

  factory JwtResponse.fromJson(Map<String, dynamic> json) => _$JwtResponseFromJson(json);
}

/// User Profile Model matching backend UserResponse exactly
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String userName,
    required String email,
    required String firstName,
    required String lastName,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
}

/// Extension for additional computed properties
extension UserProfileExtension on UserProfile {
  String get displayName => '$firstName $lastName'.trim();
  String get initials => '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase();
}

/// API Response wrapper for error handling
@freezed
class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse({
    required bool success,
    T? data,
    String? error,
    Map<String, List<String>>? validationErrors,
  }) = _ApiResponse<T>;

  factory ApiResponse.success(T data) => ApiResponse(success: true, data: data);
  factory ApiResponse.error(String error) => ApiResponse(success: false, error: error);
  factory ApiResponse.validationError(Map<String, List<String>> validationErrors) => 
    ApiResponse(success: false, validationErrors: validationErrors);
}