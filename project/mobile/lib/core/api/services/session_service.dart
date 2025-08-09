import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/session_models.dart';
import '../../../config/api_config.dart';

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

  factory ApiResponse.validationError(Map<String, List<String>> errors) {
    return ApiResponse(success: false, validationErrors: errors);
  }
}

class SessionService {
  static const String _baseUrl = ApiConfig.baseUrl;
  String? _accessToken;

  SessionService({String? accessToken}) : _accessToken = accessToken;

  void updateToken(String? token) {
    _accessToken = token;
  }

  Map<String, String> get _headers {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (_accessToken != null && _accessToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    return headers;
  }

  /// Create a new game session
  Future<ApiResponse<CreateSessionResponse>> createSession(
    CreateSessionRequest request,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sessions'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );

      debugPrint(
        'SessionService: Create session response status: ${response.statusCode}',
      );
      debugPrint(
        'SessionService: Create session response body: ${response.body}',
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse.success(
          CreateSessionResponse.fromJson(responseData),
        );
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        if (errorData.containsKey('errors')) {
          final validationErrors = <String, List<String>>{};
          final errors = errorData['errors'] as Map<String, dynamic>;
          errors.forEach((key, value) {
            validationErrors[key] = List<String>.from(value as List);
          });
          return ApiResponse.validationError(validationErrors);
        }
        return ApiResponse.error(
          errorData['message'] as String? ?? 'Validation failed',
        );
      } else if (response.statusCode == 401) {
        return ApiResponse.error('Authentication required');
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>?;
        return ApiResponse.error(
          errorData?['message'] as String? ?? 'Failed to create session',
        );
      }
    } on SocketException {
      return ApiResponse.error(
        'Network connection failed. Please check your internet connection.',
      );
    } on FormatException {
      return ApiResponse.error('Invalid response format from server');
    } catch (e) {
      debugPrint('SessionService: Create session error: $e');
      return ApiResponse.error('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Get session details by ID
  Future<ApiResponse<GameSession>> getSession(String sessionId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/sessions/$sessionId'),
        headers: _headers,
      );

      debugPrint(
        'SessionService: Get session response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse.success(GameSession.fromJson(responseData));
      } else if (response.statusCode == 404) {
        return ApiResponse.error('Session not found');
      } else if (response.statusCode == 401) {
        return ApiResponse.error('Authentication required');
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>?;
        return ApiResponse.error(
          errorData?['message'] as String? ?? 'Failed to get session',
        );
      }
    } on SocketException {
      return ApiResponse.error(
        'Network connection failed. Please check your internet connection.',
      );
    } on FormatException {
      return ApiResponse.error('Invalid response format from server');
    } catch (e) {
      debugPrint('SessionService: Get session error: $e');
      return ApiResponse.error('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Join a session using session code
  Future<ApiResponse<JoinSessionResponse>> joinSession(
    String sessionCode,
    JoinSessionRequest request,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sessions/$sessionCode/join'),
        headers: _headers,
        body: jsonEncode(request.toJson()),
      );

      debugPrint(
        'SessionService: Join session response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse.success(JoinSessionResponse.fromJson(responseData));
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        if (errorData.containsKey('errors')) {
          final validationErrors = <String, List<String>>{};
          final errors = errorData['errors'] as Map<String, dynamic>;
          errors.forEach((key, value) {
            validationErrors[key] = List<String>.from(value as List);
          });
          return ApiResponse.validationError(validationErrors);
        }
        return ApiResponse.error(
          errorData['message'] as String? ?? 'Failed to join session',
        );
      } else if (response.statusCode == 404) {
        return ApiResponse.error('Session not found');
      } else if (response.statusCode == 409) {
        return ApiResponse.error('Session is full or already started');
      } else if (response.statusCode == 401) {
        return ApiResponse.error('Authentication required');
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>?;
        return ApiResponse.error(
          errorData?['message'] as String? ?? 'Failed to join session',
        );
      }
    } on SocketException {
      return ApiResponse.error(
        'Network connection failed. Please check your internet connection.',
      );
    } on FormatException {
      return ApiResponse.error('Invalid response format from server');
    } catch (e) {
      debugPrint('SessionService: Join session error: $e');
      return ApiResponse.error('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Leave a session
  Future<ApiResponse<void>> leaveSession(String sessionId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sessions/$sessionId/leave'),
        headers: _headers,
      );

      debugPrint(
        'SessionService: Leave session response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(null);
      } else if (response.statusCode == 404) {
        return ApiResponse.error('Session not found');
      } else if (response.statusCode == 401) {
        return ApiResponse.error('Authentication required');
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>?;
        return ApiResponse.error(
          errorData?['message'] as String? ?? 'Failed to leave session',
        );
      }
    } on SocketException {
      return ApiResponse.error(
        'Network connection failed. Please check your internet connection.',
      );
    } on FormatException {
      return ApiResponse.error('Invalid response format from server');
    } catch (e) {
      debugPrint('SessionService: Leave session error: $e');
      return ApiResponse.error('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Start a game session (host only)
  Future<ApiResponse<GameSession>> startSession(String sessionId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sessions/$sessionId/start'),
        headers: _headers,
      );

      debugPrint(
        'SessionService: Start session response status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse.success(GameSession.fromJson(responseData));
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse.error(
          errorData['message'] as String? ?? 'Cannot start session',
        );
      } else if (response.statusCode == 403) {
        return ApiResponse.error('Only the host can start the session');
      } else if (response.statusCode == 404) {
        return ApiResponse.error('Session not found');
      } else if (response.statusCode == 401) {
        return ApiResponse.error('Authentication required');
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>?;
        return ApiResponse.error(
          errorData?['message'] as String? ?? 'Failed to start session',
        );
      }
    } on SocketException {
      return ApiResponse.error(
        'Network connection failed. Please check your internet connection.',
      );
    } on FormatException {
      return ApiResponse.error('Invalid response format from server');
    } catch (e) {
      debugPrint('SessionService: Start session error: $e');
      return ApiResponse.error('An unexpected error occurred: ${e.toString()}');
    }
  }

  void dispose() {
    // Cleanup any resources if needed
  }
}
