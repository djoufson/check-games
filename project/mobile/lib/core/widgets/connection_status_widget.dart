import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../providers/signalr_provider.dart';

class ConnectionStatusWidget extends StatelessWidget {
  final bool showText;
  final bool isCompact;

  const ConnectionStatusWidget({
    super.key,
    this.showText = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SignalRProvider>(
      builder: (context, signalRProvider, child) {
        if (isCompact) {
          return _buildCompactIndicator(signalRProvider);
        }
        return _buildFullIndicator(signalRProvider);
      },
    );
  }

  Widget _buildCompactIndicator(SignalRProvider signalRProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: signalRProvider.connectionStatusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: signalRProvider.connectionStatusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: signalRProvider.connectionStatusColor,
              shape: BoxShape.circle,
            ),
          ),
          if (showText) ...[
            const SizedBox(width: 6),
            Text(
              signalRProvider.connectionStatusText,
              style: AppTypography.labelSmall.copyWith(
                color: signalRProvider.connectionStatusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFullIndicator(SignalRProvider signalRProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkGrey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status indicator
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: signalRProvider.connectionStatusColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: signalRProvider.connectionStatusColor.withValues(alpha: 0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          
          if (showText) ...[
            const SizedBox(width: 8),
            Text(
              signalRProvider.connectionStatusText,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.darkGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          // Reconnect button for failed connections
          if (signalRProvider.hasFailed) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: () => signalRProvider.reconnect(),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.refresh,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],

          // Loading indicator for connecting states
          if (signalRProvider.isConnecting || signalRProvider.isReconnecting) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  signalRProvider.connectionStatusColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ConnectionStatusBanner extends StatelessWidget {
  const ConnectionStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SignalRProvider>(
      builder: (context, signalRProvider, child) {
        // Only show banner for non-connected states
        if (signalRProvider.isConnected) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: signalRProvider.hasFailed 
                ? AppColors.error.withValues(alpha: 0.1)
                : AppColors.secondary.withValues(alpha: 0.1),
            border: Border(
              bottom: BorderSide(
                color: signalRProvider.hasFailed 
                    ? AppColors.error.withValues(alpha: 0.3)
                    : AppColors.secondary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                signalRProvider.hasFailed 
                    ? Icons.wifi_off 
                    : Icons.wifi_tethering,
                size: 16,
                color: signalRProvider.connectionStatusColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getBannerMessage(signalRProvider),
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.darkGrey,
                  ),
                ),
              ),
              if (signalRProvider.hasFailed)
                TextButton(
                  onPressed: () => signalRProvider.reconnect(),
                  child: Text(
                    'Retry',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _getBannerMessage(SignalRProvider signalRProvider) {
    if (signalRProvider.hasFailed) {
      return 'Real-time features unavailable. Check your connection.';
    } else if (signalRProvider.isConnecting) {
      return 'Connecting to game server...';
    } else if (signalRProvider.isReconnecting) {
      return 'Reconnecting to game server...';
    } else {
      return 'Not connected to game server';
    }
  }
}