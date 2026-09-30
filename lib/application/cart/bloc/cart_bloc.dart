import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_app/application/cart/bloc/cart_event.dart';
import 'package:shopping_app/application/cart/bloc/cart_state.dart';
import 'package:shopping_app/domain/cart_model/cart_item_model.dart';

/// Manages the shopping cart — all operations are synchronous (no API calls).
///
/// The cart lives in memory for the duration of the session.
/// Every event emits a completely new CartState (immutable state pattern).
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<IncreaseQuantity>(_onIncreaseQuantity);
    on<DecreaseQuantity>(_onDecreaseQuantity);
    on<ClearCart>(_onClearCart);
  }

  // ── Add ───────────────────────────────────────────────────────────────────

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) {
    final items = List<CartItemModel>.from(state.items);
    final index = _indexOfProduct(items, event.product.id);

    if (index == -1) {
      // Product not in cart — add it with quantity 1.
      items.add(CartItemModel(product: event.product, quantity: 1));
    } else {
      // Product already in cart — increment quantity.
      items[index] = items[index].increment();
    }

    emit(CartState(items: items));
  }

  // ── Remove ────────────────────────────────────────────────────────────────

  void _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) {
    final items = state.items
        .where((item) => item.product.id != event.productId)
        .toList();
    emit(CartState(items: items));
  }

  // ── Increase quantity ─────────────────────────────────────────────────────

  void _onIncreaseQuantity(IncreaseQuantity event, Emitter<CartState> emit) {
    final items = List<CartItemModel>.from(state.items);
    final index = _indexOfProduct(items, event.productId);
    if (index == -1) return; // safety guard
    items[index] = items[index].increment();
    emit(CartState(items: items));
  }

  // ── Decrease quantity ─────────────────────────────────────────────────────

  /// Decrements quantity. Removes the item if quantity would reach 0.
  void _onDecreaseQuantity(DecreaseQuantity event, Emitter<CartState> emit) {
    final items = List<CartItemModel>.from(state.items);
    final index = _indexOfProduct(items, event.productId);
    if (index == -1) return; // safety guard

    if (items[index].quantity <= 1) {
      // Quantity would reach 0 — remove the item entirely.
      items.removeAt(index);
    } else {
      items[index] = items[index].decrement();
    }

    emit(CartState(items: items));
  }

  // ── Clear ─────────────────────────────────────────────────────────────────

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(const CartState()); // empty list
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  int _indexOfProduct(List<CartItemModel> items, int productId) {
    return items.indexWhere((item) => item.product.id == productId);
  }
}
