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
          final currentUserId = authProvider.user?.id;

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
                          // Session Info Card
                          _buildSessionInfoCard(session, isHost),

                          const SizedBox(height: 24),

                          // Share Section
                          if (isHost) _buildShareSection(session),
                          if (isHost) const SizedBox(height: 24),

                          // Players Section
                          Expanded(
                            child: _buildPlayersSection(session, currentUserId),
                          ),

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

  Widget _buildSessionInfoCard(GameSession session, bool isHost) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.name,
                        style: AppTypography.headlineMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Session Code: ${session.code}',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.darkGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      session.status,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
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
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  isHost ? Icons.star : Icons.person,
                  size: 16,
                  color: isHost ? AppColors.warmCoral : AppColors.mediumGrey,
                ),
                const SizedBox(width: 8),
                Text(
                  isHost ? 'You are the host' : 'Waiting for host to start',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.mediumGrey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareSection(GameSession session) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invite Players',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Share this link with others to join the session:',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.mediumGrey,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.lightGrey, width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      session.shareableLink,
                      style: AppTypography.bodySmall.copyWith(
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _copyShareableLink(session.shareableLink),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.copy,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _shareSession(session),
                icon: const Icon(Icons.share),
                label: const Text('Share Link'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayersSection(GameSession session, String? currentUserId) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Players',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${session.players.length}/${session.maxPlayers}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.mediumGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final player = session.players[index];
                        final isCurrentUser = player == currentUserId;
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
      padding: const EdgeInsets.all(12),
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
            radius: 20,
            backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
            child: Text(
              player,
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.secondary,
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

  Color _getStatusColor(SessionStatus status) {
    switch (status) {
      case SessionStatus.waiting:
        return AppColors.secondary;
      case SessionStatus.inProgress:
        return AppColors.primary;
      case SessionStatus.completed:
        return AppColors.mediumGrey;
      case SessionStatus.cancelled:
        return AppColors.error;
    }
  }

  String _getStatusText(SessionStatus status) {
    switch (status) {
      case SessionStatus.waiting:
        return 'Waiting';
      case SessionStatus.inProgress:
        return 'In Progress';
      case SessionStatus.completed:
        return 'Completed';
      case SessionStatus.cancelled:
        return 'Cancelled';
    }
  }

  void _copyShareableLink(String link) {
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Link copied to clipboard!',
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
}
