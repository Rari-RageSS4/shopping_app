import 'package:equatable/equatable.dart';

/// All events the ProductBloc can receive.
///
/// DESIGN RULE: Only one "mode" is active at a time:
///   - Normal browsing (all products, optional sort)
///   - Search mode (query string active)
///   - Category filter mode (category slug active)
///
/// Any new LoadProducts / SearchProducts / FilterByCategory resets the list
/// and starts from page 1. LoadMoreProducts appends to the existing list.
abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object?> get props => [];
}

/// Loads the first page of all products (or resets to first page).
/// Triggered on: app start, pull-to-refresh, clearing search/filter.
class LoadProducts extends ProductEvent {
  const LoadProducts({this.sortBy, this.order});

  final String? sortBy; // e.g. "price", "rating", "title"
  final String? order;  // "asc" or "desc"

  @override
  List<Object?> get props => [sortBy, order];
}

/// Appends the next page of products to the existing list.
///
/// TRIGGERED BY: scroll controller detecting the user is near the bottom.
/// GUARDED IN BLOC: ignored if already loading or if hasMore == false.
class LoadMoreProducts extends ProductEvent {
  const LoadMoreProducts();
}

/// Switches to search mode and fetches the first page for [query].
/// Replaces the current product list entirely.
class SearchProducts extends ProductEvent {
  const SearchProducts({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Switches to category-filter mode.
/// [categorySlug] null = clear the filter (show all products).
class FilterByCategory extends ProductEvent {
  const FilterByCategory({this.categorySlug});

  final String? categorySlug;

  @override
  List<Object?> get props => [categorySlug];
}

/// Changes the sort order of the current product list.
class SortProducts extends ProductEvent {
  const SortProducts({required this.sortBy, required this.order});

  final String sortBy;
  final String order;

  @override
  List<Object?> get props => [sortBy, order];
}

/// Retries the last failed pagination request (LoadMoreProducts).
class RetryLoadMore extends ProductEvent {
  const RetryLoadMore();
}
