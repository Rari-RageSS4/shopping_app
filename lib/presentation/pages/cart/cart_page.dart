import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_app/application/cart/bloc/cart_bloc.dart';
import 'package:shopping_app/application/cart/bloc/cart_event.dart';
import 'package:shopping_app/application/cart/bloc/cart_state.dart';
import 'package:shopping_app/core/routes/app_router.dart';
import 'package:shopping_app/core/theme/app_theme.dart';
import 'package:shopping_app/domain/cart_model/cart_item_model.dart';
import 'package:shopping_app/presentation/widgets/cart_item_tile.dart';
import 'package:shopping_app/presentation/widgets/confirm_dialog.dart';
import 'package:shopping_app/presentation/widgets/empty_state_view.dart';

/// Cart page — lists cart items and lets the user change quantities,
/// remove items (button or swipe, with Undo), clear the cart and see totals.
///
/// All state lives in CartBloc; this widget only dispatches events.
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  // ── Actions ────────────────────────────────────────────────────────────────

  /// Removes an item and offers Undo. Undo restores the item and its quantity
  /// (it is re-added at the end of the list).
  void _removeItem(BuildContext context, CartItemModel item) {
    final bloc = context.read<CartBloc>();
    bloc.add(RemoveFromCart(productId: item.product.id));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '${item.product.title} removed',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          action: SnackBarAction(
            label: 'Undo',
            textColor: AppTheme.accent,
            onPressed: () {
              bloc.add(AddToCart(product: item.product));
              for (var i = 1; i < item.quantity; i++) {
                bloc.add(IncreaseQuantity(productId: item.product.id));
              }
            },
          ),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  Future<void> _confirmClear(BuildContext context, int itemCount) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Clear cart?',
      message: itemCount == 1
          ? '1 item will be removed from your cart.'
          : '$itemCount items will be removed from your cart.',
      confirmLabel: 'Clear',
      destructive: true,
    );
    if (confirmed && context.mounted) {
      context.read<CartBloc>().add(const ClearCart());
    }
  }

  void _checkout(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Checkout is not part of this demo yet.')),
      );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cart) {
        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: Text(cart.isEmpty ? 'Cart' : 'Cart (${cart.totalItems})'),
            actions: [
              if (!cart.isEmpty)
                IconButton(
                  onPressed: () => _confirmClear(context, cart.totalItems),
                  icon: const Icon(Icons.delete_sweep_outlined),
                  tooltip: 'Clear cart',
                ),
              const SizedBox(width: AppTheme.spacingXs),
            ],
          ),
          body: cart.isEmpty ? _buildEmpty(context) : _buildCart(context, cart),
        );
      },
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return EmptyStateView(
      title: 'Your cart is empty',
      subtitle: 'Add something you love and it will show up here.',
      icon: Icons.shopping_cart_outlined,
      actionLabel: 'Start Shopping',
      actionIcon: Icons.storefront_outlined,
      onAction: () =>
          context.canPop() ? context.pop() : context.goNamed(AppRoutes.home),
    );
  }

  Widget _buildCart(BuildContext context, CartState cart) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            itemCount: cart.items.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppTheme.spacingMd),
            itemBuilder: (context, index) {
              final item = cart.items[index];
              final bloc = context.read<CartBloc>();

              // Swipe left to delete, or use the trash button.
              return Dismissible(
                key: ValueKey(item.product.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => _removeItem(context, item),
                background: const _DismissBackground(),
                child: CartItemTile(
                  item: item,
                  onIncrease: () => bloc
                      .add(IncreaseQuantity(productId: item.product.id)),
                  onDecrease: () => bloc
                      .add(DecreaseQuantity(productId: item.product.id)),
                  onRemove: () => _removeItem(context, item),
                ),
              );
            },
          ),
        ),
        _SummaryBar(cart: cart, onCheckout: () => _checkout(context)),
      ],
    );
  }
}

/// Red panel revealed while swiping an item away.
class _DismissBackground extends StatelessWidget {
  const _DismissBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.error,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: const Icon(Icons.delete_outline_rounded,
          color: AppTheme.textOnDark),
    );
  }
}

/// Bottom bar with savings, total and the checkout button.
class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.cart, required this.onCheckout});

  final CartState cart;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // How much the discounts save compared with the original prices.
    final savings = cart.items.fold<double>(
      0,
      (sum, item) =>
          sum + (item.product.price - item.product.discountedPrice) * item.quantity,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXl),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (savings > 0.005) ...[
                _SummaryRow(
                  label: 'You save',
                  value: '\$${savings.toStringAsFixed(2)}',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: AppTheme.success),
                ),
                const SizedBox(height: AppTheme.spacingXs),
              ],
              _SummaryRow(
                label: 'Total',
                value: '\$${cart.totalPrice.toStringAsFixed(2)}',
                style: textTheme.headlineMedium,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              ElevatedButton(
                onPressed: onCheckout,
                child: const Text('Checkout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.style,
  });

  final String label;
  final String value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}