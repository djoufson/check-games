class ApiConfig {
  // TODO: Update with actual API base URL
  static const String baseUrl = 'http://localhost:5277/api';

  // SignalR Hub URL
  static const String signalRHubUrl = 'http://localhost:5277/gamehub';

  // Request timeout duration
  static const Duration requestTimeout = Duration(seconds: 30);

  // JWT token key for local storage
  static const String tokenKey = 'auth_tokens';
  static const String userKey = 'user_profile';
  static const String anonymousKey = 'is_anonymous';
}
