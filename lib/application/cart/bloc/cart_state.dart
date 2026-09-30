import 'package:equatable/equatable.dart';
import 'package:shopping_app/domain/cart_model/cart_item_model.dart';

/// Single rich state for the entire cart.
///
/// Unlike product/auth which have multiple state classes, the cart always
/// has a state — it just might be empty. One class is simpler and easier
/// to explain than a hierarchy.
class CartState extends Equatable {
  const CartState({this.items = const []});

  final List<CartItemModel> items;

  // ── Computed properties ───────────────────────────────────────────────────

  /// Total number of individual units across all cart items.
  /// Used for the cart badge on the bottom nav bar / app bar icon.
  int get totalItems =>
      items.fold(0, (sum, item) => sum + item.quantity);

  /// Total price of all items (discounted prices × quantities).
  double get totalPrice =>
      items.fold(0.0, (sum, item) => sum + item.itemTotal);

  /// True when the cart has no items.
  bool get isEmpty => items.isEmpty;

  @override
  List<Object?> get props => [items];
}
