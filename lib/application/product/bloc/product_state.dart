import 'package:equatable/equatable.dart';
import 'package:shopping_app/domain/product_model/product_model.dart';

/// All states the ProductBloc can emit.
abstract class ProductState extends Equatable {
  const ProductState();
  @override
  List<Object?> get props => [];
}

/// Initial — nothing has been loaded yet.
class ProductInitial extends ProductState {
  const ProductInitial();
}

/// First page is being fetched. Shows a full-screen loading indicator.
class ProductLoading extends ProductState {
  const ProductLoading();
}

/// Products are loaded and displayed.
///
/// KEY FIELDS FOR INFINITE SCROLL:
/// [isLoadingMore] — true while a subsequent page is being fetched.
///                   The UI shows a spinner at the bottom of the list.
/// [hasMore]       — false when skip + limit >= total (all products loaded).
///                   The UI shows "You've seen everything" and stops triggering.
/// [totalAvailable] — the API's total count, used to calculate hasMore.
class ProductLoaded extends ProductState {
  const ProductLoaded({
    required this.products,
    required this.hasMore,
    required this.totalAvailable,
    this.isLoadingMore = false,
    this.activeCategory,
    this.activeSearch,
    this.sortBy,
    this.order,
  });

  final List<ProductModel> products;
  final bool hasMore;          // false = reached the end of available products
  final int totalAvailable;    // total from API response
  final bool isLoadingMore;    // true = bottom spinner visible
  final String? activeCategory; // set when category filter is active
  final String? activeSearch;   // set when search is active
  final String? sortBy;         // current sort field
  final String? order;          // "asc" or "desc"

  /// Creates a copy of this state with selected fields overridden.
  /// Used in the BLoC to update individual fields without reconstructing everything.
  ProductLoaded copyWith({
    List<ProductModel>? products,
    bool? hasMore,
    int? totalAvailable,
    bool? isLoadingMore,
    String? activeCategory,
    String? activeSearch,
    String? sortBy,
    String? order,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      hasMore: hasMore ?? this.hasMore,
      totalAvailable: totalAvailable ?? this.totalAvailable,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      activeCategory: activeCategory ?? this.activeCategory,
      activeSearch: activeSearch ?? this.activeSearch,
      sortBy: sortBy ?? this.sortBy,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [
        products,
        hasMore,
        totalAvailable,
        isLoadingMore,
        activeCategory,
        activeSearch,
        sortBy,
        order,
      ];
}

/// First-page fetch failed entirely. Shows a full-screen error view with retry.
class ProductError extends ProductState {
  const ProductError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Pagination (page 2+) failed. The existing product list is still visible,
/// but a "Retry" button appears at the bottom instead of the loading spinner.
class ProductLoadMoreError extends ProductState {
  const ProductLoadMoreError({
    required this.products,
    required this.message,
    required this.totalAvailable,
    this.activeCategory,
    this.activeSearch,
    this.sortBy,
    this.order,
  });

  final List<ProductModel> products;
  final String message;
  final int totalAvailable;
  final String? activeCategory;
  final String? activeSearch;
  final String? sortBy;
  final String? order;

  @override
  List<Object?> get props => [products, message, totalAvailable];
}
