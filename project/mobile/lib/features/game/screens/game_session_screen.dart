import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/widgets/connection_status_widget.dart';
import '../../../core/api/models/session_models.dart';
import '../providers/session_provider.dart';

class GameSessionScreen extends StatefulWidget {
  final String sessionId;

  const GameSessionScreen({super.key, required this.sessionId});

  @override
  State<GameSessionScreen> createState() => _GameSessionScreenState();
}

class _GameSessionScreenState extends State<GameSessionScreen> {
  @override
  void initState() {
    super.initState();
    // Load session data and join SignalR room
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SessionProvider>().loadSession(widget.sessionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Game Session',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          const ConnectionStatusWidget(isCompact: true, showText: false),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer2<SessionProvider, AuthProvider>(
        builder: (context, sessionProvider, authProvider, child) {
          if (sessionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (sessionProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Session Error',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      sessionProvider.error!,
                      style: AppTypography.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Back to Home'),
                  ),
                ],
              ),
            );
          }

          final session = sessionProvider.currentSession;
          if (session == null) {
            return const Center(child: Text('Session not found'));
          }

          final isHost = session.hostId == authProvider.user?.id;
          final currentUserName = authProvider.user?.userName;

          return Container(
            decoration: const BoxDecoration(gradient: AppColors.softGradient),
            child: SafeArea(
              child: Column(
                children: [
                  // Connection status banner
                  const ConnectionStatusBanner(),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        20.0,
                        16.0,
                        20.0,
                        20.0,
                      ), // Optimized padding
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Combined Session Info and Share Card (more compact)
                          _buildCompactSessionCard(session, isHost),

                          const SizedBox(height: 16),

                          // Players Section (more space allocated)
                          Expanded(
                            child: _buildPlayersSection(
                              session,
                              currentUserName,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Action Buttons
                          _buildActionButtons(session, isHost, sessionProvider),
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

  /// Build a compact session card that combines info and share functionality
  Widget _buildCompactSessionCard(GameSession session, bool isHost) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Reduced padding from 20 to 16
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Session header with title, code, and status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.name,
                        style: AppTypography.titleLarge.copyWith(
                          // Reduced from headlineMedium
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Code: ${session.code}',
                        style: AppTypography.bodyMedium.copyWith(
                          // Reduced from titleMedium
                          color: AppColors.darkGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badge and share button in same row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          session.status,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getStatusColor(session.status),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getStatusText(session.status),
                        style: AppTypography.labelSmall.copyWith(
                          color: _getStatusColor(session.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isHost) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _shareSession(session),
                        icon: const Icon(Icons.share),
                        tooltip: 'Share Session',
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.1,
                          ),
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Session stats and quick share for hosts
            Row(
              children: [
                // Session stats
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        isHost ? Icons.star : Icons.person,
                        size: 16,
                        color: isHost
                            ? AppColors.warmCoral
                            : AppColors.mediumGrey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isHost
                            ? 'You are the host'
                            : 'Waiting for host to start',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.mediumGrey,
                        ),
                      ),
                    ],
                  ),
                ),

                // Quick copy session code for hosts
                if (isHost)
                  InkWell(
                    onTap: () => _copySessionCode(session.code),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.copy, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Copy Code',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayersSection(GameSession session, String? currentUserName) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Reduced padding from 20 to 16
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // More compact header with better visual hierarchy
            Row(
              children: [
                Icon(Icons.people, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Players',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${session.players.length}/${session.maxPlayers}',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12), // Reduced spacing from 16 to 12
            Expanded(
              child: session.players.isEmpty
                  ? Center(
                      child: Text(
                        'No players yet',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.mediumGrey,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: session.players.length,
                      separatorBuilder: (context, index) => const SizedBox(
                        height: 8,
                      ), // Reduced spacing between players
                      itemBuilder: (context, index) {
                        final player = session.players[index];
                        final isCurrentUser = player == currentUserName;
                        return _buildPlayerCard(player, isCurrentUser);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCard(String player, bool isCurrentUser) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ), // More compact padding
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.lightGrey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrentUser ? AppColors.primary : AppColors.lightGrey,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16, // Reduced from 20 to 16
            backgroundColor: isCurrentUser
                ? AppColors.primary.withValues(alpha: 0.2)
                : AppColors.secondary.withValues(alpha: 0.2),
            child: Text(
              _getPlayerInitials(player),
              style: AppTypography.labelLarge.copyWith(
                // Reduced from titleSmall
                color: isCurrentUser ? AppColors.primary : AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      player,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Text(
                        '(You)',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.person, size: 16, color: AppColors.mediumGrey),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    GameSession session,
    bool isHost,
    SessionProvider sessionProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _leaveSession(sessionProvider),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error),
              ),
              child: const Text('Leave Session'),
            ),
          ),
          if (isHost && session.canStart) ...[
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => _startSession(sessionProvider),
                child: const Text('Start Game'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(GameSessionStatus status) {
    switch (status) {
      case GameSessionStatus.waitingForPlayers:
        return AppColors.secondary;
      case GameSessionStatus.inProgress:
        return AppColors.primary;
      case GameSessionStatus.completed:
        return AppColors.mediumGrey;
      case GameSessionStatus.cancelled:
        return AppColors.error;
    }
  }

  String _getStatusText(GameSessionStatus status) {
    switch (status) {
      case GameSessionStatus.waitingForPlayers:
        return 'Waiting';
      case GameSessionStatus.inProgress:
        return 'In Progress';
      case GameSessionStatus.completed:
        return 'Completed';
      case GameSessionStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Copy session code to clipboard
  void _copySessionCode(String sessionCode) {
    Clipboard.setData(ClipboardData(text: sessionCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Session code copied to clipboard!',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.secondary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareSession(GameSession session) {
    final shareText =
        'Join my Check Games session: ${session.name}\n'
        'Session Code: ${session.code}\n'
        'Link: ${session.shareableLink}';

    // Note: For sharing functionality, you would typically use a package like share_plus
    // For now, we'll just copy to clipboard
    Clipboard.setData(ClipboardData(text: shareText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Session details copied to clipboard!',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.secondary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _leaveSession(SessionProvider sessionProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Leave Session'),
          content: const Text('Are you sure you want to leave this session?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                sessionProvider.leaveSession();
                Navigator.of(context).pop(); // Go back to home screen
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Leave'),
            ),
          ],
        );
      },
    );
  }

  void _startSession(SessionProvider sessionProvider) {
    sessionProvider.startSession();
  }

  /// Generate initials from a username
  String _getPlayerInitials(String username) {
    if (username.isEmpty) return 'U';

    // If username has spaces, take first letter of first two words
    final parts = username.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    // Otherwise, take first two characters or just first if only one character
    if (username.length >= 2) {
      return username.substring(0, 2).toUpperCase();
    }

    return username[0].toUpperCase();
  }
}
