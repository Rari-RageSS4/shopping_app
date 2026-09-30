import 'package:equatable/equatable.dart';
import 'package:shopping_app/domain/product_model/product_model.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

/// Adds a product to the cart. If it already exists, increments quantity.
class AddToCart extends CartEvent {
  const AddToCart({required this.product});
  final ProductModel product;
  @override
  List<Object?> get props => [product.id];
}

/// Removes a product from the cart entirely (regardless of quantity).
class RemoveFromCart extends CartEvent {
  const RemoveFromCart({required this.productId});
  final int productId;
  @override
  List<Object?> get props => [productId];
}

/// Increments the quantity of a cart item by 1.
class IncreaseQuantity extends CartEvent {
  const IncreaseQuantity({required this.productId});
  final int productId;
  @override
  List<Object?> get props => [productId];
}

/// Decrements the quantity of a cart item by 1.
/// If quantity reaches 0, the item is removed from the cart.
class DecreaseQuantity extends CartEvent {
  const DecreaseQuantity({required this.productId});
  final int productId;
  @override
  List<Object?> get props => [productId];
}

/// Removes all items from the cart.
class ClearCart extends CartEvent {
  const ClearCart();
}
