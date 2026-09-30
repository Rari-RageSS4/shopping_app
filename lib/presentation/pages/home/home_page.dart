import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_app/application/auth/bloc/auth_bloc.dart';
import 'package:shopping_app/application/auth/bloc/auth_event.dart';
import 'package:shopping_app/application/cart/bloc/cart_bloc.dart';
import 'package:shopping_app/application/cart/bloc/cart_event.dart';
import 'package:shopping_app/application/cart/bloc/cart_state.dart';
import 'package:shopping_app/application/category/bloc/category_bloc.dart';
import 'package:shopping_app/application/category/bloc/category_event.dart';
import 'package:shopping_app/application/category/bloc/category_state.dart';
import 'package:shopping_app/application/product/bloc/product_bloc.dart';
import 'package:shopping_app/application/product/bloc/product_event.dart';
import 'package:shopping_app/application/product/bloc/product_state.dart';
import 'package:shopping_app/core/constants/app_constants.dart';
import 'package:shopping_app/core/routes/app_router.dart';
import 'package:shopping_app/core/theme/app_theme.dart';
import 'package:shopping_app/domain/product_model/product_model.dart';
import 'package:shopping_app/presentation/widgets/category_chip.dart';
import 'package:shopping_app/presentation/widgets/confirm_dialog.dart';
import 'package:shopping_app/presentation/widgets/empty_state_view.dart';
import 'package:shopping_app/presentation/widgets/error_view.dart';
import 'package:shopping_app/presentation/widgets/loading_indicator.dart';
import 'package:shopping_app/presentation/widgets/product_card.dart';

/// Home page — the main shopping browse experience.
///
/// STRUCTURE (one CustomScrollView, one scroll position):
///   SliverAppBar        logo, sort, cart badge, logout + search bar
///   Category chips      + active-filter row
///   Product grid        2 columns (3 on tablets)
///   Footer              loading spinner / retry / "end of list"
///
/// INFINITE SCROLL:
///   The ScrollController is attached to the CustomScrollView that contains
///   the grid, so its position is the real list position. When the user
///   passes [AppConstants.scrollTriggerFraction] of the list, LoadMoreProducts
///   is dispatched. This widget contains no pagination logic of its own.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce; // prevents firing a search on every keystroke

  /// Remembers which sort option was picked last. Price asc/desc share the
  /// same `sortBy`, so this is how the sheet and filter chip tell them apart.
  _SortOption? _lastSort;

  static const _sortOptions = [
    _SortOption(label: 'Default', sortBy: null, order: null),
    _SortOption(label: 'Price: Low to High', sortBy: 'price', order: 'asc'),
    _SortOption(label: 'Price: High to Low', sortBy: 'price', order: 'desc'),
    _SortOption(label: 'Rating: Best First', sortBy: 'rating', order: 'desc'),
    _SortOption(label: 'Name: A–Z', sortBy: 'title', order: 'asc'),
  ];

  // ── Layout constants ───────────────────────────────────────────────────────
  static const double _searchBarHeight = 48 + AppTheme.spacingMd;
  static const double _tabletBreakpoint = 600;
  static const double _filterBadgeMaxWidth = 160;
  static const int _skeletonCount = 6;

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const LoadProducts());
    context.read<CategoryBloc>().add(const LoadCategories());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ── Infinite scroll listener ───────────────────────────────────────────────

  /// Dispatches LoadMoreProducts once the user is near the end of the list.
  /// Only fires when there is more to load and nothing is loading already.
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels <
        position.maxScrollExtent * AppConstants.scrollTriggerFraction) {
      return;
    }

    final state = context.read<ProductBloc>().state;
    if (state is ProductLoaded && state.hasMore && !state.isLoadingMore) {
      context.read<ProductBloc>().add(const LoadMoreProducts());
    }
  }

  // ── Search ─────────────────────────────────────────────────────────────────

  /// Waits [searchDebounceMsec] after the last keystroke before searching.
  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: AppConstants.searchDebounceMsec),
      () => context.read<ProductBloc>().add(SearchProducts(query: query)),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<ProductBloc>().add(const LoadProducts());
  }

  // ── Sort ───────────────────────────────────────────────────────────────────

  /// The option matching the bloc's current `sortBy` (null = Default).
  _SortOption? _selectedSortOption(String? sortBy) {
    if (sortBy == null) return null;
    if (_lastSort?.sortBy == sortBy) return _lastSort;
    return _sortOptions.firstWhere(
      (o) => o.sortBy == sortBy,
      orElse: () => _sortOptions.first,
    );
  }

  void _showSortSheet() {
    final productState = context.read<ProductBloc>().state;
    final active = _selectedSortOption(
          productState is ProductLoaded ? productState.sortBy : null,
        ) ??
        _sortOptions.first;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      showDragHandle: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXl),
        ),
      ),
      builder: (sheetContext) => _SortSheet(
        options: _sortOptions,
        active: active,
        onSelected: (option) {
          Navigator.pop(sheetContext);
          _lastSort = option;
          if (option.sortBy == null) {
            context.read<ProductBloc>().add(const LoadProducts());
          } else {
            context.read<ProductBloc>().add(
                  SortProducts(sortBy: option.sortBy!, order: option.order!),
                );
          }
        },
      ),
    );
  }

  // ── Cart snackbar ──────────────────────────────────────────────────────────

  void _addToCart(ProductModel product) {
    context.read<CartBloc>().add(AddToCart(product: product));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar() // rapid taps replace the message, not queue it
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline,
                  color: AppTheme.accent, size: 18),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: Text(
                  '${product.title} added to cart',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          action: SnackBarAction(
            label: 'View Cart',
            textColor: AppTheme.accent,
            onPressed: () => context.pushNamed(AppRoutes.cart),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  /// Asks for confirmation, then dispatches LogoutRequested.
  /// AuthBloc clears the Hive session and the router returns to Login.
  Future<void> _confirmLogout() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Log out?',
      message: 'You will need to sign in again to continue shopping.',
      confirmLabel: 'Log out',
      destructive: true,
    );
    if (confirmed && mounted) {
      context.read<AuthBloc>().add(const LogoutRequested());
    }
  }

  void _openProduct(ProductModel product) {
    context.pushNamed(AppRoutes.productDetail, extra: product);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildCategoryRow(),
                _buildActiveFilterRow(),
              ],
            ),
          ),
          BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) => _buildProducts(state),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.paddingOf(context).bottom + AppTheme.spacingMd,
            ),
          ),
        ],
      ),
    );
  }

  // ── App bar (collapses on scroll, returns on scroll-up) ────────────────────

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppTheme.primary,
      scrolledUnderElevation: 0,
      titleSpacing: AppTheme.spacingMd,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.accent,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: const Icon(Icons.shopping_bag_rounded,
                color: AppTheme.primary, size: 18),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Text(
            'ShopZen',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textOnDark,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _showSortSheet,
          icon: const Icon(Icons.tune_rounded),
          tooltip: 'Sort',
        ),
        BlocBuilder<CartBloc, CartState>(
          buildWhen: (prev, next) => prev.totalItems != next.totalItems,
          builder: (context, cart) {
            return IconButton(
              onPressed: () => context.pushNamed(AppRoutes.cart),
              tooltip: 'Cart',
              icon: Badge(
                isLabelVisible: cart.totalItems > 0,
                label: Text('${cart.totalItems}'),
                backgroundColor: AppTheme.accent,
                textColor: AppTheme.textOnAccent,
                child: const Icon(Icons.shopping_cart_outlined),
              ),
            );
          },
        ),
        IconButton(
          onPressed: _confirmLogout,
          icon: const Icon(Icons.logout_rounded),
          tooltip: 'Log out',
        ),
        const SizedBox(width: AppTheme.spacingXs),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(_searchBarHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spacingMd,
            0,
            AppTheme.spacingMd,
            AppTheme.spacingMd,
          ),
          child: _buildSearchField(context),
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    OutlineInputBorder border([BorderSide side = BorderSide.none]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: side,
        );

    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      textInputAction: TextInputAction.search,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: 'Search products…',
        prefixIcon: const Icon(Icons.search_rounded,
            color: AppTheme.textSecondary),
        // Rebuilds as the user types, so the clear button appears instantly.
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _searchController,
          builder: (context, value, _) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppTheme.textSecondary),
                  tooltip: 'Clear search',
                  onPressed: _clearSearch,
                ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: AppTheme.spacingSm,
          horizontal: AppTheme.spacingMd,
        ),
        border: border(),
        enabledBorder: border(),
        focusedBorder: border(const BorderSide(color: AppTheme.accent, width: 2)),
      ),
    );
  }

  // ── Category row ───────────────────────────────────────────────────────────

  Widget _buildCategoryRow() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is! CategoryLoaded) return const SizedBox.shrink();

        final productState = context.watch<ProductBloc>().state;
        final selectedSlug =
            productState is ProductLoaded ? productState.activeCategory : null;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            border: Border(bottom: BorderSide(color: AppTheme.border)),
          ),
          child: CategoryChipRow(
            categories: state.categories,
            selectedSlug: selectedSlug,
            onCategorySelected: (slug) {
              _searchController.clear();
              context
                  .read<ProductBloc>()
                  .add(FilterByCategory(categorySlug: slug));
            },
          ),
        );
      },
    );
  }

  // ── Active filters (dismissible chips + result count) ──────────────────────

  Widget _buildActiveFilterRow() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is! ProductLoaded) return const SizedBox.shrink();
        if (state.sortBy == null &&
            state.activeCategory == null &&
            state.activeSearch == null) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spacingMd,
            AppTheme.spacingSm,
            AppTheme.spacingMd,
            0,
          ),
          child: Row(
            children: [
              // Badges scroll sideways instead of overflowing.
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (state.activeSearch != null)
                        _buildFilterBadge(
                          'Search: "${state.activeSearch}"',
                          _clearSearch,
                        ),
                      if (state.activeCategory != null)
                        _buildFilterBadge(
                          state.activeCategory!,
                          () => context
                              .read<ProductBloc>()
                              .add(const FilterByCategory()),
                        ),
                      if (state.sortBy != null)
                        _buildFilterBadge(
                          _selectedSortOption(state.sortBy)?.label ??
                              'Sorted by ${state.sortBy}',
                          () => context
                              .read<ProductBloc>()
                              .add(const LoadProducts()),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Text(
                '${state.totalAvailable} products',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterBadge(String label, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(right: AppTheme.spacingSm),
      child: Chip(
        label: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _filterBadgeMaxWidth),
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        deleteIcon: const Icon(Icons.close_rounded, size: 16),
        onDeleted: onRemove,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  // ── Product area (returns a sliver for each state) ─────────────────────────

  Widget _buildProducts(ProductState state) {
    // First page loading → skeleton cards with the real card proportions.
    if (state is ProductLoading) {
      return _buildGridSliver(
        count: _skeletonCount,
        itemBuilder: (_, __) => const ProductCardSkeleton(),
      );
    }

    // First page error.
    if (state is ProductError) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorView(
          message: state.message,
          onRetry: () => context.read<ProductBloc>().add(const LoadProducts()),
        ),
      );
    }

    // Loaded (normal / loading more / end of list).
    if (state is ProductLoaded) {
      if (state.products.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyStateView(
            title: state.activeSearch != null
                ? 'No results for "${state.activeSearch}"'
                : 'No products found',
            subtitle: state.activeSearch != null
                ? 'Try a different search term'
                : 'Try selecting a different category',
            icon: Icons.search_off_rounded,
            actionLabel: 'Clear Filter',
            onAction: () {
              _clearSearch();
              context.read<ProductBloc>().add(const FilterByCategory());
            },
          ),
        );
      }
      return SliverMainAxisGroup(
        slivers: [
          _buildProductGrid(state.products),
          SliverToBoxAdapter(child: _buildFooter(state)),
        ],
      );
    }

    // Pagination error — the list stays visible with a retry button below it.
    if (state is ProductLoadMoreError) {
      return SliverMainAxisGroup(
        slivers: [
          _buildProductGrid(state.products),
          SliverToBoxAdapter(
            child: InlineErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<ProductBloc>().add(const RetryLoadMore()),
            ),
          ),
        ],
      );
    }

    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }

  Widget _buildProductGrid(List<ProductModel> products) {
    return _buildGridSliver(
      count: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          onTap: () => _openProduct(product),
          onAddToCart: () => _addToCart(product),
        );
      },
    );
  }

  /// A 2-column grid (3 on tablets). Each tile's height comes from
  /// [ProductCard.extentFor], so cards are exactly as tall as their content
  /// on every screen width and text scale.
  Widget _buildGridSliver({
    required int count,
    required NullableIndexedWidgetBuilder itemBuilder,
  }) {
    const spacing = AppTheme.spacingMd;

    return SliverPadding(
      padding: const EdgeInsets.all(spacing),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final columns =
              MediaQuery.sizeOf(context).width >= _tabletBreakpoint ? 3 : 2;
          final tileWidth =
              (constraints.crossAxisExtent - spacing * (columns - 1)) /
                  columns;

          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              mainAxisExtent: ProductCard.extentFor(context, tileWidth),
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => itemBuilder(context, index)!,
              childCount: count,
            ),
          );
        },
      ),
    );
  }

  // ── Footer ─────────────────────────────────────────────────────────────────

  Widget _buildFooter(ProductLoaded state) {
    if (state.isLoadingMore) return const BottomLoadingIndicator();
    if (!state.hasMore) return _buildEndOfList();
    return const SizedBox(height: AppTheme.spacingLg);
  }

  Widget _buildEndOfList() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingLg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline_rounded,
              size: 16, color: AppTheme.success),
          const SizedBox(width: AppTheme.spacingSm),
          Text(
            'You\'ve seen everything',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ── Sort helpers ──────────────────────────────────────────────────────────────

class _SortOption {
  const _SortOption({
    required this.label,
    required this.sortBy,
    required this.order,
  });
  final String label;
  final String? sortBy;
  final String? order;
}

class _SortSheet extends StatelessWidget {
  const _SortSheet({
    required this.options,
    required this.active,
    required this.onSelected,
  });

  final List<_SortOption> options;
  final _SortOption active;
  final ValueChanged<_SortOption> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingMd,
        0,
        AppTheme.spacingMd,
        AppTheme.spacingLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sort by', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppTheme.spacingSm),
          for (final option in options)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(option.label),
              selected: option.label == active.label,
              selectedColor: AppTheme.primary,
              trailing: option.label == active.label
                  ? const Icon(Icons.check_rounded, color: AppTheme.accent)
                  : null,
              onTap: () => onSelected(option),
            ),
        ],
      ),
    );
  }
}