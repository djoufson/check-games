import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/models/auth_models.dart';
import '../api/services/auth_service.dart';

enum AuthStatus {
  initial,
  authenticated,
  anonymous,
  unauthenticated,
  loading,
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  
  AuthStatus _status = AuthStatus.initial;
  UserProfile? _user;
  JwtResponse? _tokens;
  String? _error;
  Timer? _tokenRefreshTimer;

  AuthProvider({AuthService? authService}) 
    : _authService = authService ?? AuthService() {
    _checkStoredAuth();
  }

  // Getters
  AuthStatus get status => _status;
  UserProfile? get user => _user;
  String? get error => _error;
  String? get accessToken => _tokens?.accessToken;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _user != null;
  bool get isAnonymous => _status == AuthStatus.anonymous;
  bool get isGuest => _status == AuthStatus.anonymous;
  bool get isLoading => _status == AuthStatus.loading;
  bool get canCreateGames => isAuthenticated;
  bool get canJoinGames => isAuthenticated || isAnonymous;
  bool get canAccessSettings => true;

  /// Check if user authentication is stored locally
  Future<void> _checkStoredAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokensJson = prefs.getString('auth_tokens');
      final userJson = prefs.getString('user_profile');
      final isAnonymous = prefs.getBool('is_anonymous') ?? false;

      if (tokensJson != null && userJson != null) {
        _tokens = JwtResponse.fromJson(jsonDecode(tokensJson));
        _user = UserProfile.fromJson(jsonDecode(userJson));

        // Check if token is still valid
        if (_tokens!.expiresAt.isAfter(DateTime.now().add(const Duration(minutes: 5)))) {
          _status = AuthStatus.authenticated;
          _scheduleTokenRefresh();
        } else {
          // Try to refresh token
          await _refreshToken();
        }
      } else if (isAnonymous) {
        _status = AuthStatus.anonymous;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      await _clearStoredAuth();
    }
    
    notifyListeners();
  }

  /// Store authentication data locally
  Future<void> _storeAuth(JwtResponse tokens, UserProfile user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_tokens', jsonEncode(tokens.toJson()));
    await prefs.setString('user_profile', jsonEncode(user.toJson()));
  }

  /// Clear stored authentication data
  Future<void> _clearStoredAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_tokens');
    await prefs.remove('user_profile');
    await prefs.remove('is_anonymous');
  }

  /// Register a new user
  Future<bool> register(RegisterRequest request) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    final response = await _authService.register(request);

    if (response.success) {
      // Registration successful, now log them in
      final loginRequest = LoginRequest(
        email: request.email,
        password: request.password,
      );
      
      final loginResult = await login(loginRequest);
      return loginResult;
    } else {
      _status = AuthStatus.unauthenticated;
      _error = response.error ?? _formatValidationErrors(response.validationErrors);
      notifyListeners();
      return false;
    }
  }

  /// Login with email and password
  Future<bool> login(LoginRequest request) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    final response = await _authService.login(request);

    if (response.success && response.data != null) {
      _tokens = response.data!;
      
      // Extract user info from JWT token (simplified - in production you might want a separate endpoint)
      // For now, we'll create a basic user profile from the email
      _user = UserProfile(
        id: 'temp-id', // This should come from a separate user info endpoint
        userName: request.email.split('@')[0],
        firstName: 'User',
        lastName: 'Name',
        email: request.email,
      );

      await _storeAuth(_tokens!, _user!);
      _status = AuthStatus.authenticated;
      _scheduleTokenRefresh();
      notifyListeners();
      return true;
    } else {
      _status = AuthStatus.unauthenticated;
      _error = response.error ?? _formatValidationErrors(response.validationErrors);
      notifyListeners();
      return false;
    }
  }

  /// Refresh the access token
  Future<void> _refreshToken() async {
    if (_tokens?.refreshToken == null) {
      await logout();
      return;
    }

    final response = await _authService.refreshToken(_tokens!.refreshToken);

    if (response.success && response.data != null) {
      _tokens = response.data!;
      if (_user != null) {
        await _storeAuth(_tokens!, _user!);
      }
      _status = AuthStatus.authenticated;
      _scheduleTokenRefresh();
    } else {
      await logout();
    }
    
    notifyListeners();
  }

  /// Schedule automatic token refresh
  void _scheduleTokenRefresh() {
    _tokenRefreshTimer?.cancel();
    
    if (_tokens != null) {
      final now = DateTime.now();
      final expiresAt = _tokens!.expiresAt;
      final refreshTime = expiresAt.subtract(const Duration(minutes: 5));
      
      if (refreshTime.isAfter(now)) {
        final duration = refreshTime.difference(now);
        _tokenRefreshTimer = Timer(duration, () {
          _refreshToken();
        });
      }
    }
  }

  /// Continue as guest (anonymous user)
  Future<void> continueAsGuest() async {
    _status = AuthStatus.anonymous;
    _user = null;
    _tokens = null;
    _error = null;
    
    // Store anonymous status
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_anonymous', true);
    
    notifyListeners();
  }

  /// Logout the user
  Future<void> logout() async {
    _tokenRefreshTimer?.cancel();
    _status = AuthStatus.unauthenticated;
    _user = null;
    _tokens = null;
    _error = null;
    
    await _clearStoredAuth();
    notifyListeners();
  }

  /// Clear any error messages
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Format validation errors for display
  String _formatValidationErrors(Map<String, List<String>>? errors) {
    if (errors == null || errors.isEmpty) {
      return 'Validation failed. Please check your input.';
    }

    final errorMessages = <String>[];
    errors.forEach((field, messages) {
      errorMessages.addAll(messages);
    });

    return errorMessages.join('\n');
  }

  @override
  void dispose() {
    _tokenRefreshTimer?.cancel();
    _authService.dispose();
    super.dispose();
  }
}