import 'package:flutter/material.dart';
import 'package:shopping_app/core/theme/app_theme.dart';
import 'package:shopping_app/presentation/widgets/empty_state_view.dart';

/// Reusable full-screen error view.
///
/// Shows an icon, message, and a retry button.
/// Used for both first-page load failures and as a stand-alone error screen.
/// Built on [EmptyStateView] so error and empty states look consistent.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    this.title = 'Something went wrong',
  });

  final String message;
  final VoidCallback onRetry;
  final String title;

  @override
  Widget build(BuildContext context) {
    return EmptyStateView(
      title: title,
      subtitle: message,
      icon: Icons.wifi_off_rounded,
      iconColor: AppTheme.error,
      actionLabel: 'Try Again',
      actionIcon: Icons.refresh_rounded,
      onAction: onRetry,
    );
  }
}

/// Small inline error shown at the bottom of a list when pagination fails.
/// Keeps the existing product list visible with a retry button beneath it.
class InlineErrorView extends StatelessWidget {
  const InlineErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        children: [
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primary,
              side: const BorderSide(color: AppTheme.border),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMd,
                vertical: AppTheme.spacingSm,
              ),
            ),
          ),
        ],
      ),
    );
  }
}