import 'package:flutter/material.dart';
import 'package:mobile/features/game/widgets/join_session_dialog.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/api/models/auth_models.dart';
import '../../../core/widgets/connection_status_widget.dart';
import '../../game/providers/session_provider.dart';
import '../../game/widgets/create_session_dialog.dart';
import '../../game/screens/game_session_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Check Games',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Connection status indicator
          const ConnectionStatusWidget(isCompact: true, showText: false),
          const SizedBox(width: 8),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'logout') {
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                  } else if (value == 'login') {
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                  } else if (value == 'profile') {
                    _showProfileDialog(context, authProvider);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  if (authProvider.isAuthenticated)
                    PopupMenuItem<String>(
                      value: 'profile',
                      child: Row(
                        children: [
                          const Icon(Icons.person, color: AppColors.darkGrey),
                          const SizedBox(width: 8),
                          Text('Profile', style: AppTypography.bodyMedium),
                        ],
                      ),
                    ),
                  if (authProvider.isAnonymous)
                    PopupMenuItem<String>(
                      value: 'login',
                      child: Row(
                        children: [
                          const Icon(Icons.login, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Sign In',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (authProvider.isAuthenticated)
                    PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          const Icon(Icons.logout, color: AppColors.error),
                          const SizedBox(width: 8),
                          Text(
                            'Logout',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                    backgroundColor: AppColors.white.withValues(alpha: 0.2),
                    child: Text(
                      authProvider.isAuthenticated &&
                              authProvider.user?.firstName.isNotEmpty == true
                          ? authProvider.user!.firstName[0].toUpperCase()
                          : authProvider.isAnonymous
                          ? 'G'
                          : 'U',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;

          return Container(
            decoration: const BoxDecoration(gradient: AppColors.softGradient),
            child: SafeArea(
              child: Column(
                children: [
                  // Connection status banner
                  const ConnectionStatusBanner(),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome Section
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    authProvider.isAnonymous
                                        ? 'Welcome, Guest!'
                                        : 'Welcome back,',
                                    style: AppTypography.bodyLarge.copyWith(
                                      color: AppColors.mediumGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    authProvider.isAnonymous
                                        ? 'Guest Player'
                                        : user?.displayName ??
                                              user?.userName ??
                                              'Player',
                                    style: AppTypography.headlineMedium
                                        .copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    authProvider.isAnonymous
                                        ? 'Join games or sign up for full features!'
                                        : 'Ready for another game?',
                                    style: AppTypography.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Quick Actions
                          Text(
                            'Quick Actions',
                            style: AppTypography.headlineSmall,
                          ),
                          const SizedBox(height: 16),

                          // Action Buttons
                          Expanded(
                            child: GridView.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.1, // Adjust card aspect ratio
                              physics: const BouncingScrollPhysics(),
                              children: [
                                _buildActionCard(
                                  context,
                                  authProvider: authProvider,
                                  title: 'Create Game',
                                  subtitle: 'Start a new session',
                                  icon: Icons.add_circle,
                                  color: AppColors.primary,
                                  enabled: authProvider.canCreateGames,
                                  onTap: () =>
                                      _handleCreateGame(context, authProvider),
                                ),
                                _buildActionCard(
                                  context,
                                  authProvider: authProvider,
                                  title: 'Join Game',
                                  subtitle: 'Enter game code',
                                  icon: Icons.group_add,
                                  color: AppColors.secondary,
                                  enabled: authProvider.canJoinGames,
                                  onTap: () =>
                                      _handleJoinGame(context, authProvider),
                                ),
                                _buildActionCard(
                                  context,
                                  authProvider: authProvider,
                                  title: 'Game History',
                                  subtitle: 'View past games',
                                  icon: Icons.history,
                                  color: AppColors.warmCoral,
                                  enabled: authProvider.isAuthenticated,
                                  onTap: () {
                                    if (authProvider.isAuthenticated) {
                                      // TODO: Navigate to game history screen
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Game history feature coming soon!',
                                            style: AppTypography.bodyMedium,
                                          ),
                                          backgroundColor: AppColors.secondary,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Please sign in to view game history',
                                            style: AppTypography.bodyMedium,
                                          ),
                                          backgroundColor: AppColors.warmCoral,
                                        ),
                                      );
                                    }
                                  },
                                ),
                                _buildActionCard(
                                  context,
                                  authProvider: authProvider,
                                  title: 'Settings',
                                  subtitle: 'Preferences',
                                  icon: Icons.settings,
                                  color: AppColors.mediumGrey,
                                  enabled: authProvider.canAccessSettings,
                                  onTap: () {
                                    // TODO: Navigate to settings screen
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Settings feature coming soon!',
                                          style: AppTypography.bodyMedium,
                                        ),
                                        backgroundColor: AppColors.secondary,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required AuthProvider authProvider,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Opacity(
          opacity: enabled ? 1.0 : 0.5,
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Reduced padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // Prevent overflow
              children: [
                Container(
                  width: 48, // Slightly smaller icon container
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: enabled ? 0.1 : 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 24, // Smaller icon
                    color: enabled ? color : color.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 8), // Reduced spacing
                Flexible(
                  child: Text(
                    title,
                    style: AppTypography.titleSmall.copyWith(
                      // Smaller title
                      fontWeight: FontWeight.bold,
                      color: enabled ? AppColors.darkGrey : AppColors.lightGrey,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2, // Limit lines to prevent overflow
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!enabled && !authProvider.isAuthenticated)
                        const Icon(
                          Icons.lock,
                          size: 10,
                          color: AppColors.lightGrey,
                        ),
                      if (!enabled && !authProvider.isAuthenticated)
                        const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          subtitle,
                          style: AppTypography.labelSmall.copyWith(
                            // Even smaller subtitle
                            color: enabled
                                ? AppColors.mediumGrey
                                : AppColors.lightGrey,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1, // Single line to prevent overflow
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Handle create game action
  void _handleCreateGame(BuildContext context, AuthProvider authProvider) {
    if (!authProvider.canCreateGames) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please sign in to create games',
            style: AppTypography.bodyMedium,
          ),
          backgroundColor: AppColors.warmCoral,
        ),
      );
      return;
    }

    showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) => const CreateSessionDialog(),
    ).then((result) {
      if (result != null && context.mounted) {
        _createGameSession(
          context,
          authProvider,
          sessionName: result['sessionName'] as String,
          maxPlayers: result['maxPlayers'] as int,
        );
      }
    });
  }

  /// Handle create game action
  void _handleJoinGame(BuildContext context, AuthProvider authProvider) {
    showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) => const JoinSessionDialog(),
    ).then((result) {
      if (result != null && context.mounted) {
        // {'sessionCode': sessionCode, 'playerName': playerName}
        _joinGameSession(
          context,
          authProvider,
          sessionCode: result['sessionCode'] as String,
          playerName: result['playerName'] as String,
        );
      }
    });
  }

  /// Create a new game session
  Future<void> _createGameSession(
    BuildContext context,
    AuthProvider authProvider, {
    required String sessionName,
    required int maxPlayers,
  }) async {
    final sessionProvider = context.read<SessionProvider>();

    // Update session provider with current access token
    sessionProvider.updateAccessToken(authProvider.accessToken);

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Creating session...', style: AppTypography.bodyMedium),
            ],
          ),
        );
      },
    );

    try {
      final success = await sessionProvider.createSession(
        description: sessionName,
        maxPlayersLimit: maxPlayers,
      );

      if (context.mounted) {
        // Close loading dialog
        Navigator.of(context).pop();

        if (success && sessionProvider.currentSession != null) {
          // Navigate to game session screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => GameSessionScreen(
                sessionId: sessionProvider.currentSession!.id,
              ),
            ),
          );
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                sessionProvider.error ?? 'Failed to create session',
                style: AppTypography.bodyMedium,
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        // Close loading dialog
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'An unexpected error occurred',
              style: AppTypography.bodyMedium,
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Join a game session
  Future<void> _joinGameSession(
    BuildContext context,
    AuthProvider authProvider, {
    required String sessionCode,
    required String playerName,
  }) async {
    final sessionProvider = context.read<SessionProvider>();

    // Update session provider with current access token
    sessionProvider.updateAccessToken(authProvider.accessToken);

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Joining session...', style: AppTypography.bodyMedium),
            ],
          ),
        );
      },
    );

    try {
      final success = await sessionProvider.joinSession(
        sessionCode,
        playerName,
      );

      if (context.mounted) {
        // Close loading dialog
        Navigator.of(context).pop();

        if (success && sessionProvider.currentSession != null) {
          
          // Navigate to game session screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => GameSessionScreen(
                sessionId: sessionProvider.currentSession!.id,
              ),
            ),
          );
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                sessionProvider.error ?? 'Failed to create session',
                style: AppTypography.bodyMedium,
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        // Close loading dialog
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'An unexpected error occurred',
              style: AppTypography.bodyMedium,
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Show user profile dialog
  void _showProfileDialog(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.user;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                radius: 20,
                child: Text(
                  user.initials,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Profile',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileField('Display Name', user.displayName),
              const SizedBox(height: 12),
              _buildProfileField('Username', user.userName),
              const SizedBox(height: 12),
              _buildProfileField('Email', user.email),
              const SizedBox(height: 12),
              _buildProfileField('First Name', user.firstName),
              const SizedBox(height: 12),
              _buildProfileField('Last Name', user.lastName),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(
                    Icons.refresh,
                    size: 16,
                    color: AppColors.mediumGrey,
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: () async {
                      await authProvider.refreshUserProfile();
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        _showProfileDialog(context, authProvider);
                      }
                    },
                    child: Text(
                      'Refresh Data',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build a profile field row
  Widget _buildProfileField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.mediumGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.isNotEmpty ? value : 'Not provided',
          style: AppTypography.bodyMedium.copyWith(
            color: value.isNotEmpty ? AppColors.darkGrey : AppColors.mediumGrey,
            fontStyle: value.isNotEmpty ? FontStyle.normal : FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
