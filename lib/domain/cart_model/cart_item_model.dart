import 'package:shopping_app/domain/product_model/product_model.dart';

/// CartItemModel — a product that has been added to the cart with a quantity.
///
/// This model is LOCAL ONLY — it never goes to any API.
/// The CartBloc manages a list of CartItemModel in memory.
///
/// If you want to persist the cart across app restarts,
/// CartItemModel.toJson() / fromJson() can be used with a Hive box.
class CartItemModel {
  const CartItemModel({
    required this.product,
    required this.quantity,
  });

  final ProductModel product;
  final int quantity; // must be >= 1

  // ── Computed helpers ──────────────────────────────────────────────────────

  /// Total price for this line item: discounted price × quantity.
  double get itemTotal => product.discountedPrice * quantity;

  // ── Immutable update helpers ──────────────────────────────────────────────
  // These return a new CartItemModel instead of mutating the existing one.
  // This is important for BLoC — states must be immutable.

  /// Returns a new CartItemModel with quantity incremented by 1.
  CartItemModel increment() => CartItemModel(
        product: product,
        quantity: quantity + 1,
      );

  /// Returns a new CartItemModel with quantity decremented by 1.
  /// The caller should remove the item from the cart if quantity reaches 0.
  CartItemModel decrement() => CartItemModel(
        product: product,
        quantity: quantity - 1,
      );

  // ── Serialization ─────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
    );
  }

  // ── Equality ──────────────────────────────────────────────────────────────
  // Quantity MUST be part of equality. CartState compares its item list with
  // Equatable, and if two items with different quantities were "equal", Bloc
  // would skip the emit and the UI would never update on + / − / re-add.

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CartItemModel &&
          other.product.id == product.id &&
          other.quantity == quantity);

  @override
  int get hashCode => Object.hash(product.id, quantity);

  @override
  String toString() =>
      'CartItemModel(productId: ${product.id}, qty: $quantity)';
}