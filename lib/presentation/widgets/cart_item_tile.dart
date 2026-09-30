import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shopping_app/core/theme/app_theme.dart';
import 'package:shopping_app/domain/cart_model/cart_item_model.dart';

/// One line in the cart: thumbnail, title, unit price, quantity stepper,
/// line total and a delete button.
///
/// Purely presentational — the parent decides what each callback does
/// (dispatching to CartBloc), which keeps this widget easy to reuse.
class CartItemTile extends StatelessWidget {
  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  final CartItemModel item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  static const double _thumbSize = 88;

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThumbnail(product.thumbnail),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + delete button.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.title,
                          style: textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingXs),
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: IconButton(
                          onPressed: onRemove,
                          padding: EdgeInsets.zero,
                          iconSize: 20,
                          color: AppTheme.textSecondary,
                          tooltip: 'Remove from cart',
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingXs),

                  // Unit price (discounted, with original struck through).
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatPrice(product.discountedPrice),
                          style: textTheme.titleLarge?.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (product.discountPercentage > 0) ...[
                          const SizedBox(width: AppTheme.spacingXs),
                          Text(
                            _formatPrice(product.price),
                            style: textTheme.bodySmall?.copyWith(
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),

                  // Quantity stepper + line total.
                  Row(
                    children: [
                      _QuantityStepper(
                        quantity: item.quantity,
                        onIncrease: onIncrease,
                        onDecrease: onDecrease,
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _formatPrice(item.itemTotal),
                              style: textTheme.titleMedium,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: SizedBox(
        width: _thumbSize,
        height: _thumbSize,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (_, __) => const ColoredBox(
            color: AppTheme.background,
            child: Center(
              child: CircularProgressIndicator(
                color: AppTheme.accent,
                strokeWidth: 2,
              ),
            ),
          ),
          errorWidget: (_, __, ___) => const ColoredBox(
            color: AppTheme.background,
            child: Icon(
              Icons.image_not_supported_outlined,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  static String _formatPrice(double value) => '\$${value.toStringAsFixed(2)}';
}

/// Pill-shaped  −  qty  +  control. The number animates when it changes.
class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
  });

  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove_rounded,
            tooltip: 'Decrease quantity',
            onPressed: onDecrease,
          ),
          SizedBox(
            width: 28,
            child: Center(
              child: AnimatedSwitcher(
                duration: AppTheme.durationFast,
                child: Text(
                  '$quantity',
                  key: ValueKey(quantity),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            tooltip: 'Increase quantity',
            onPressed: onIncrease,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: 16,
      color: AppTheme.primary,
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 32, height: 32),
    );
  }
}