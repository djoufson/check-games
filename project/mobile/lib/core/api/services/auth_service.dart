import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_models.dart';
import '../../../config/api_config.dart';

class AuthService {
  static const String _baseUrl = '${ApiConfig.baseUrl}/auth';

  final http.Client _client;

  AuthService({http.Client? client}) : _client = client ?? http.Client();

  /// Register a new user
  Future<ApiResponse<String>> register(RegisterRequest request) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        // Backend returns user ID on successful registration
        final userId = jsonDecode(response.body) as String;
        return ApiResponse.success(userId);
      } else if (response.statusCode == 409) {
        return ApiResponse.error('User already exists with this email');
      } else if (response.statusCode == 400) {
        // Handle validation errors
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic> &&
              errorData.containsKey('errors')) {
            final errors = Map<String, List<String>>.from(
              errorData['errors'].map(
                (key, value) => MapEntry(key, List<String>.from(value)),
              ),
            );
            return ApiResponse.validationError(errors);
          }
        } catch (_) {
          // Fall through to generic error
        }
        return ApiResponse.error(
          'Registration failed. Please check your input.',
        );
      } else {
        return ApiResponse.error('Registration failed. Please try again.');
      }
    } catch (e) {
      return ApiResponse.error('Network error. Please check your connection.');
    }
  }

  /// Login with email and password
  Future<ApiResponse<JwtResponse>> login(LoginRequest request) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final jwtResponse = JwtResponse.fromJson(data);
        return ApiResponse.success(jwtResponse);
      } else if (response.statusCode == 401) {
        return ApiResponse.error('Invalid email or password');
      } else if (response.statusCode == 400) {
        // Handle validation errors
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic> &&
              errorData.containsKey('errors')) {
            final errors = Map<String, List<String>>.from(
              errorData['errors'].map(
                (key, value) => MapEntry(key, List<String>.from(value)),
              ),
            );
            return ApiResponse.validationError(errors);
          }
        } catch (_) {
          // Fall through to generic error
        }
        return ApiResponse.error('Login failed. Please check your input.');
      } else {
        return ApiResponse.error('Login failed. Please try again.');
      }
    } catch (e) {
      return ApiResponse.error('Network error. Please check your connection.');
    }
  }

  /// Refresh access token using refresh token
  Future<ApiResponse<JwtResponse>> refreshToken(String refreshToken) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final jwtResponse = JwtResponse.fromJson(data);
        return ApiResponse.success(jwtResponse);
      } else if (response.statusCode == 401) {
        return ApiResponse.error('Invalid or expired refresh token');
      } else {
        return ApiResponse.error('Token refresh failed. Please login again.');
      }
    } catch (e) {
      return ApiResponse.error('Network error. Please check your connection.');
    }
  }

  /// Fetch current user data using access token
  Future<ApiResponse<UserProfile>> getCurrentUser(String accessToken) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final userProfile = UserProfile.fromJson(data);
        return ApiResponse.success(userProfile);
      } else if (response.statusCode == 401) {
        return ApiResponse.error('Authentication required');
      } else if (response.statusCode == 404) {
        return ApiResponse.error('User not found');
      } else {
        return ApiResponse.error('Failed to fetch user data');
      }
    } catch (e) {
      return ApiResponse.error('Network error. Please check your connection.');
    }
  }

  /// Dispose of HTTP client
  void dispose() {
    _client.close();
  }
}
