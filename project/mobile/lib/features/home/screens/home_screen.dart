import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CheckGame',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'logout') {
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/login');
                    }
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        const Icon(Icons.person, color: AppColors.darkGrey),
                        const SizedBox(width: 8),
                        Text(
                          'Profile',
                          style: AppTypography.bodyMedium,
                        ),
                      ],
                    ),
                  ),
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
                      authProvider.user?.firstName.isNotEmpty == true 
                          ? authProvider.user!.firstName[0].toUpperCase()
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
            decoration: const BoxDecoration(
              gradient: AppColors.softGradient,
            ),
            child: SafeArea(
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
                              'Welcome back,',
                              style: AppTypography.bodyLarge.copyWith(
                                color: AppColors.mediumGrey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.displayName ?? user?.userName ?? 'Player',
                              style: AppTypography.headlineMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ready for another game?',
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
                        children: [
                          _buildActionCard(
                            context,
                            title: 'Create Game',
                            subtitle: 'Start a new session',
                            icon: Icons.add_circle,
                            color: AppColors.primary,
                            onTap: () {
                              // TODO: Navigate to create game screen
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Create game feature coming soon!',
                                    style: AppTypography.bodyMedium,
                                  ),
                                  backgroundColor: AppColors.secondary,
                                ),
                              );
                            },
                          ),
                          _buildActionCard(
                            context,
                            title: 'Join Game',
                            subtitle: 'Enter game code',
                            icon: Icons.group_add,
                            color: AppColors.secondary,
                            onTap: () {
                              // TODO: Navigate to join game screen
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Join game feature coming soon!',
                                    style: AppTypography.bodyMedium,
                                  ),
                                  backgroundColor: AppColors.secondary,
                                ),
                              );
                            },
                          ),
                          _buildActionCard(
                            context,
                            title: 'Game History',
                            subtitle: 'View past games',
                            icon: Icons.history,
                            color: AppColors.warmCoral,
                            onTap: () {
                              // TODO: Navigate to game history screen
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Game history feature coming soon!',
                                    style: AppTypography.bodyMedium,
                                  ),
                                  backgroundColor: AppColors.secondary,
                                ),
                              );
                            },
                          ),
                          _buildActionCard(
                            context,
                            title: 'Settings',
                            subtitle: 'Preferences',
                            icon: Icons.settings,
                            color: AppColors.mediumGrey,
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
          );
        },
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.mediumGrey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}