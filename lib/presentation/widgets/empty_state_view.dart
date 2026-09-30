import 'package:flutter/material.dart';
import 'package:shopping_app/core/theme/app_theme.dart';

/// Shown when a list has no items or a screen has nothing to display —
/// empty search results, empty category, load failures, etc.
///
/// [ErrorView] reuses this widget with an error colour and a retry action,
/// so both states share one layout.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.search_off_rounded,
    this.iconColor = AppTheme.primary,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  static const double _maxContentWidth = 320;
  static const Size _buttonSize = Size(160, 48);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    // Gentle fade + rise on first show.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppTheme.durationNormal,
      curve: Curves.easeOut,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, (1 - t) * 12), child: child),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxContentWidth),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingXl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Two soft rings around the icon.
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacingLg),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 40,
                      color: iconColor.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLg),
                Text(
                  title,
                  style: theme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  subtitle,
                  style: theme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: AppTheme.spacingLg),
                  _buildAction(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAction() {
    final style = ElevatedButton.styleFrom(minimumSize: _buttonSize);
    return actionIcon == null
        ? ElevatedButton(
            onPressed: onAction,
            style: style,
            child: Text(actionLabel!),
          )
        : ElevatedButton.icon(
            onPressed: onAction,
            style: style,
            icon: Icon(actionIcon),
            label: Text(actionLabel!),
          );
  }
}