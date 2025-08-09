import 'package:flutter/material.dart';
import 'package:mobile/core/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class JoinSessionDialog extends StatefulWidget {
  const JoinSessionDialog({super.key});

  @override
  State<JoinSessionDialog> createState() => _JoinSessionDialogState();
}

class _JoinSessionDialogState extends State<JoinSessionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _sessionCodeController = TextEditingController();
  final _playerNameController = TextEditingController();
  final bool _isLoading = false;

  @override
  void dispose() {
    _sessionCodeController.dispose();
    super.dispose();
  }

  String? _validatePlayerName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Player name is required';
    }
    if (value.trim().length < 3) {
      return 'Player name must be at least 3 characters';
    }
    if (value.trim().length > 30) {
      return 'Player name must be less than 30 characters';
    }
    return null;
  }

  String? _validateSessionCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Session code is required';
    }
    if (value.trim().length != 6) {
      return 'Session code must be 6 characters';
    }

    return null;
  }

  void _joinSession() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final sessionCode = _sessionCodeController.text.trim();
    final playerName = _playerNameController.text.trim();
    Navigator.of(
      context,
    ).pop({'sessionCode': sessionCode, 'playerName': playerName});
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return AlertDialog(
      title: Text(
        'Join Game Session',
        style: AppTypography.headlineSmall.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Session Code Field
            TextFormField(
              controller: _sessionCodeController,
              decoration: InputDecoration(
                labelText: 'Session Code',
                hintText: 'Enter the session code',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
              validator: _validateSessionCode,
              enabled: !_isLoading,
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 20),
            if (!authProvider.isAuthenticated)
              Column(
                children: [
                  TextFormField(
                    controller: _playerNameController,
                    decoration: InputDecoration(
                      labelText: 'Your name',
                      hintText: 'Enter the name you want to see displayed',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                    validator: _validatePlayerName,
                    enabled: !_isLoading,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : () => _joinSession(),
          child: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                )
              : const Text('Create Session'),
        ),
      ],
    );
  }
}
