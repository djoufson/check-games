import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class CreateSessionDialog extends StatefulWidget {
  const CreateSessionDialog({super.key});

  @override
  State<CreateSessionDialog> createState() => _CreateSessionDialogState();
}

class _CreateSessionDialogState extends State<CreateSessionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _sessionNameController = TextEditingController();
  int _maxPlayers = 4;
  final bool _isLoading = false;

  @override
  void dispose() {
    _sessionNameController.dispose();
    super.dispose();
  }

  String? _validateSessionName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Session name is required';
    }
    if (value.trim().length < 3) {
      return 'Session name must be at least 3 characters';
    }
    if (value.trim().length > 30) {
      return 'Session name must be less than 30 characters';
    }
    return null;
  }

  void _createSession() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final sessionName = _sessionNameController.text.trim();
    Navigator.of(
      context,
    ).pop({'sessionName': sessionName, 'maxPlayers': _maxPlayers});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Create Game Session',
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
            // Session Name Field
            TextFormField(
              controller: _sessionNameController,
              decoration: InputDecoration(
                labelText: 'Session Name',
                hintText: 'Enter a name for your game session',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
              validator: _validateSessionName,
              enabled: !_isLoading,
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 20),

            // Max Players Selection
            Text(
              'Maximum Players',
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.lightGrey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _maxPlayers,
                  isExpanded: true,
                  onChanged: _isLoading
                      ? null
                      : (int? newValue) {
                          setState(() {
                            _maxPlayers = newValue ?? 4;
                          });
                        },
                  items: [2, 3, 4, 5, 6, 8].map<DropdownMenuItem<int>>((
                    int value,
                  ) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(
                        '$value players',
                        style: AppTypography.bodyMedium,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You will be the host and can start the game once at least 2 players have joined.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ),
                ],
              ),
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
          onPressed: _isLoading ? null : _createSession,
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
