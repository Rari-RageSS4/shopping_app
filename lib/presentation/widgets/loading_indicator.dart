import 'package:flutter/material.dart';
import 'package:shopping_app/core/theme/app_theme.dart';

/// A full-screen loading indicator shown during first-page fetches.
///
/// Uses the app's accent colour to stay on-brand.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: AppTheme.accent,
            strokeWidth: 3,
          ),
          if (message != null) ...[
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A small inline loading indicator shown at the bottom of a list
/// while the next page of products is being fetched.
class BottomLoadingIndicator extends StatelessWidget {
  const BottomLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppTheme.spacingLg),
      child: Center(
        child: SizedBox(
          height: 28,
          width: 28,
          child: CircularProgressIndicator(
            color: AppTheme.accent,
            strokeWidth: 2.5,
          ),
        ),
      ),
    );
  }
}
