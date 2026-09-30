import 'package:flutter/material.dart';
import 'package:shopping_app/core/theme/app_theme.dart';

/// Shows a themed confirm / cancel dialog and returns true only if the user
/// confirmed. Dismissing the dialog (tap outside, back button) counts as
/// cancel.
///
/// Set [destructive] for actions like log out or delete — the confirm button
/// turns red so it reads as a serious action.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          style: TextButton.styleFrom(foregroundColor: AppTheme.textSecondary),
          child: Text(cancelLabel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          style: TextButton.styleFrom(
            foregroundColor: destructive ? AppTheme.error : AppTheme.primary,
          ),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}