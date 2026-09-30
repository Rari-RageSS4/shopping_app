import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_app/application/product/bloc/product_event.dart';
import 'package:shopping_app/application/product/bloc/product_state.dart';
import 'package:shopping_app/core/constants/api_constants.dart';
import 'package:shopping_app/domain/product_model/product_model.dart';
import 'package:shopping_app/infrastructure/api/product_api.dart';
import 'package:shopping_app/infrastructure/database/hive/product_cache.dart';

/// Manages the product list, search, category filter, sort, and infinite scroll.
///
/// INFINITE SCROLL EXPLAINED:
///   1. LoadProducts fetches page 1 (skip=0, limit=20).
///   2. The UI's scroll controller detects the user is near the bottom.
///   3. The widget dispatches LoadMoreProducts.
///   4. This BLoC checks: not already loading? hasMore == true?
///   5. If safe: fetches next page (skip = products.length, limit = 20).
///   6. Appends new products to the existing list.
///   7. Recalculates hasMore = (total products loaded < totalAvailable).
///   8. Emits updated ProductLoaded state.
///
/// MODES: Only one is active at a time.
///   - Normal: fetchProducts() with optional sort
///   - Search: searchProducts(query)
///   - Category: fetchProductsByCategory(slug)
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc({
    ProductApi? productApi,
    ProductCache? productCache,
  })  : _api = productApi ?? ProductApi(),
        _cache = productCache ?? ProductCache(),
        super(const ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadMoreProducts>(_onLoadMoreProducts);
    on<SearchProducts>(_onSearchProducts);
    on<FilterByCategory>(_onFilterByCategory);
    on<SortProducts>(_onSortProducts);
    on<RetryLoadMore>(_onRetryLoadMore);
  }

  final ProductApi _api;
  final ProductCache _cache;

  // ── LoadProducts ──────────────────────────────────────────────────────────

  /// Fetches the first page of products.
  ///
  /// CACHING FLOW:
  ///   1. Check Hive cache — if valid, emit cached products immediately.
  ///   2. Always fetch fresh data from API in the background.
  ///   3. Update cache and emit fresh state.
  ///
  /// This gives instant display from cache while keeping data up to date.
  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    // Step 1 — try to show cached products instantly (no spinner for the user).
    final cached = _cache.getCachedProducts();
    if (cached != null && cached.isNotEmpty) {
      // Emit cached data immediately so the UI isn't blank.
      // We set hasMore=true optimistically — fresh fetch will correct it.
      emit(ProductLoaded(
        products: cached,
        hasMore: true,
        totalAvailable: 0, // unknown until API responds
        sortBy: event.sortBy,
        order: event.order,
      ));
    } else {
      // No cache — show the loading spinner.
      emit(const ProductLoading());
    }

    // Step 2 — fetch fresh data from API regardless of cache.
    try {
      final response = await _api.fetchProducts(
        skip: 0,
        limit: ApiConstants.pageSize,
        sortBy: event.sortBy,
        order: event.order,
      );

      // Step 3 — update cache with fresh first page.
      await _cache.cacheProducts(response.products);

      // hasMore = true if there are more products beyond this first page.
      final hasMore = response.products.length < response.total;

      emit(ProductLoaded(
        products: response.products,
        hasMore: hasMore,
        totalAvailable: response.total,
        sortBy: event.sortBy,
        order: event.order,
      ));
    } catch (e) {
      // If we showed cached data and the API fails, don't wipe the cache view.
      if (state is! ProductLoaded) {
        emit(ProductError(message: e.toString()));
      }
      // If cached data was shown, silently fail — user sees stale but valid data.
    }
  }

  // ── LoadMoreProducts ──────────────────────────────────────────────────────

  /// Appends the next page of products to the existing list.
  ///
  /// GUARD CONDITIONS (checked before API call):
  ///   - Current state must be ProductLoaded (we have products to append to).
  ///   - isLoadingMore must be false (prevent duplicate concurrent requests).
  ///   - hasMore must be true (stop when all products are loaded).
  Future<void> _onLoadMoreProducts(
    LoadMoreProducts event,
    Emitter<ProductState> emit,
  ) async {
    final currentState = state;

    // Guard: only paginate when we have a loaded list with more pages available.
    if (currentState is! ProductLoaded) return;
    if (currentState.isLoadingMore) return; // already fetching — ignore
    if (!currentState.hasMore) return;      // no more pages — stop

    // Show loading spinner at bottom of list.
    emit(currentState.copyWith(isLoadingMore: true));

    try {
      // skip = current number of loaded products = offset for next page.
      final skip = currentState.products.length;

      ProductsResponse response;

      // Use the correct API endpoint based on the current active mode.
      if (currentState.activeSearch != null) {
        response = await _api.searchProducts(
          query: currentState.activeSearch!,
          skip: skip,
        );
      } else if (currentState.activeCategory != null) {
        response = await _api.fetchProductsByCategory(
          categorySlug: currentState.activeCategory!,
          skip: skip,
        );
      } else {
        response = await _api.fetchProducts(
          skip: skip,
          sortBy: currentState.sortBy,
          order: currentState.order,
        );
      }

      // Append new products to the existing list.
      final updatedProducts = [
        ...currentState.products,
        ...response.products,
      ];

      // hasMore = false when total loaded >= total available from API.
      final hasMore = updatedProducts.length < response.total;

      emit(currentState.copyWith(
        products: updatedProducts,
        hasMore: hasMore,
        totalAvailable: response.total,
        isLoadingMore: false,
      ));
    } catch (e) {
      // Pagination failed — show the list + retry button (not a blank error screen).
      emit(ProductLoadMoreError(
        products: currentState.products,
        message: e.toString(),
        totalAvailable: currentState.totalAvailable,
        activeCategory: currentState.activeCategory,
        activeSearch: currentState.activeSearch,
        sortBy: currentState.sortBy,
        order: currentState.order,
      ));
    }
  }

  // ── SearchProducts ────────────────────────────────────────────────────────

  /// Resets the list and fetches the first page for a search query.
  /// If [query] is empty, falls back to LoadProducts (show all products).
  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      // Empty search — treat as "clear search" and return to normal browsing.
      add(const LoadProducts());
      return;
    }

    emit(const ProductLoading());

    try {
      final response = await _api.searchProducts(query: event.query.trim());
      final hasMore = response.products.length < response.total;

      emit(ProductLoaded(
        products: response.products,
        hasMore: hasMore,
        totalAvailable: response.total,
        activeSearch: event.query.trim(),
      ));
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  // ── FilterByCategory ──────────────────────────────────────────────────────

  /// Resets the list and fetches products for a category.
  /// If [categorySlug] is null, clears the filter and shows all products.
  Future<void> _onFilterByCategory(
    FilterByCategory event,
    Emitter<ProductState> emit,
  ) async {
    if (event.categorySlug == null) {
      // No category selected — return to normal product list.
      add(const LoadProducts());
      return;
    }

    emit(const ProductLoading());

    try {
      final response = await _api.fetchProductsByCategory(
        categorySlug: event.categorySlug!,
      );
      final hasMore = response.products.length < response.total;

      emit(ProductLoaded(
        products: response.products,
        hasMore: hasMore,
        totalAvailable: response.total,
        activeCategory: event.categorySlug,
      ));
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  // ── SortProducts ──────────────────────────────────────────────────────────

  /// Reloads the current product list with a different sort order.
  Future<void> _onSortProducts(
    SortProducts event,
    Emitter<ProductState> emit,
  ) async {
    final currentState = state;

    // Determine which mode is active and reload with the new sort.
    if (currentState is ProductLoaded && currentState.activeCategory != null) {
      // Sorting within a category — re-fetch from API.
      // Note: DummyJSON category endpoint does not support sortBy as of this
      // version; we reload anyway so the UI stays consistent.
      add(FilterByCategory(categorySlug: currentState.activeCategory));
    } else {
      add(LoadProducts(sortBy: event.sortBy, order: event.order));
    }
  }

  // ── RetryLoadMore ─────────────────────────────────────────────────────────

  /// Retries the last failed pagination request.
  /// Called when the user taps "Retry" after a LoadMoreError.
  Future<void> _onRetryLoadMore(
    RetryLoadMore event,
    Emitter<ProductState> emit,
  ) async {
    final errorState = state;
    if (errorState is! ProductLoadMoreError) return;

    // Restore ProductLoaded with the existing products, then trigger next page.
    emit(ProductLoaded(
      products: errorState.products,
      hasMore: true, // assume there's more — the pagination will find out
      totalAvailable: errorState.totalAvailable,
      activeCategory: errorState.activeCategory,
      activeSearch: errorState.activeSearch,
      sortBy: errorState.sortBy,
      order: errorState.order,
    ));

    add(const LoadMoreProducts());
  }
}
