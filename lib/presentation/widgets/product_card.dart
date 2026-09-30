import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shopping_app/core/theme/app_theme.dart';
import 'package:shopping_app/domain/product_model/product_model.dart';

/// A product card shown in the 2-column home page grid.
///
/// LAYOUT (why there is no overflow and no empty space):
///   The card's height is a function of its width and the user's text scale:
///
///     height = image (width ÷ aspect ratio)
///            + padding + 2 title lines + price line + button
///
///   [extentFor] computes that number and the grid passes it as
///   `mainAxisExtent`. Text styles use an explicit line-height so the
///   maths is exact, the title always reserves two lines so every card in a
///   row lines up, and the price row scales down instead of overflowing.
///
/// INTERACTION:
/// - Tapping the card calls [onTap] — the parent navigates to ProductDetail.
/// - Tapping "Add to Cart" calls [onAddToCart].
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  });

  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  // ── Shared layout constants (used by build, skeleton and extentFor) ────────
  static const double _imageAspectRatio = 1.0;
  static const int _titleLines = 2;
  static const double _lineHeight = 1.3;
  static const EdgeInsets _infoPadding =
      EdgeInsets.all(AppTheme.spacingSm + AppTheme.spacingXs);

  /// Height a card needs for a given tile [width] at the current text scale.
  static double extentFor(BuildContext context, double width) {
    final metrics = _CardTextMetrics.of(context);
    final info = _infoPadding.vertical +
        metrics.titleBoxHeight +
        AppTheme.spacingXs +
        metrics.priceHeight +
        AppTheme.spacingSm +
        AppTheme.buttonHeightCompact;
    return (width / _imageAspectRatio + info).ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppTheme.radiusLarge);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: AppTheme.cardShadow,
      ),
      // Material + InkWell gives a proper ripple and clips the image corners.
      child: Material(
        color: AppTheme.surface,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImage(),
              Expanded(child: _buildInfo(context)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Image section ─────────────────────────────────────────────────────────

  Widget _buildImage() {
    return AspectRatio(
      aspectRatio: _imageAspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: product.thumbnail,
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
                size: 32,
              ),
            ),
          ),

          // Discount badge (top-left) — only when there is a discount.
          if (product.discountPercentage > 0)
            Positioned(
              top: AppTheme.spacingSm,
              left: AppTheme.spacingSm,
              child: _Badge(
                color: AppTheme.error,
                child: Text(
                  '-${product.discountPercentage.toStringAsFixed(0)}%',
                  style: AppTheme.badgeText,
                ),
              ),
            ),

          // Rating badge (top-right).
          Positioned(
            top: AppTheme.spacingSm,
            right: AppTheme.spacingSm,
            child: _Badge(
              color: AppTheme.scrim,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded,
                      color: AppTheme.accent, size: 12),
                  const SizedBox(width: 2),
                  Text(
                    product.rating.toStringAsFixed(1),
                    style: AppTheme.badgeText,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Info section ──────────────────────────────────────────────────────────

  Widget _buildInfo(BuildContext context) {
    final metrics = _CardTextMetrics.of(context);

    return Padding(
      padding: _infoPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Always reserves two lines so prices line up across the row.
              SizedBox(
                height: metrics.titleBoxHeight,
                child: Text(
                  product.title,
                  style: metrics.titleStyle,
                  maxLines: _titleLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: AppTheme.spacingXs),

              // Price row scales down instead of overflowing on narrow cards.
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '\$${product.discountedPrice.toStringAsFixed(2)}',
                      style: metrics.priceStyle,
                    ),
                    if (product.discountPercentage > 0) ...[
                      const SizedBox(width: AppTheme.spacingXs),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // Add to cart — pinned to the bottom of the card.
          SizedBox(
            height: AppTheme.buttonHeightCompact,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddToCart,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, AppTheme.buttonHeightCompact),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                textStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              icon: const Icon(Icons.add_shopping_cart_rounded, size: 14),
              label: const Text(
                'Add to Cart',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Text styles + line heights for the card, derived from the app theme and
/// the current text scale. Shared by [ProductCard.build] and
/// [ProductCard.extentFor] so the two can never disagree.
class _CardTextMetrics {
  const _CardTextMetrics._({
    required this.titleStyle,
    required this.priceStyle,
    required this.titleBoxHeight,
    required this.priceHeight,
  });

  factory _CardTextMetrics.of(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scaler = MediaQuery.textScalerOf(context);

    final titleStyle =
        textTheme.titleMedium!.copyWith(height: ProductCard._lineHeight);
    final priceStyle = textTheme.titleLarge!.copyWith(
      color: AppTheme.primary,
      fontWeight: FontWeight.w700,
      height: ProductCard._lineHeight,
    );

    double lineHeight(TextStyle s) => scaler.scale(s.fontSize!) * s.height!;

    return _CardTextMetrics._(
      titleStyle: titleStyle,
      priceStyle: priceStyle,
      titleBoxHeight: lineHeight(titleStyle) * ProductCard._titleLines,
      priceHeight: lineHeight(priceStyle),
    );
  }

  final TextStyle titleStyle;
  final TextStyle priceStyle;
  final double titleBoxHeight;
  final double priceHeight;
}

/// Small pill used for the discount and rating badges on the image.
class _Badge extends StatelessWidget {
  const _Badge({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: child,
    );
  }
}

/// Pulsing placeholder with the same proportions as [ProductCard].
/// Shown in the grid while the first page loads.
class ProductCardSkeleton extends StatefulWidget {
  const ProductCardSkeleton({super.key});

  @override
  State<ProductCardSkeleton> createState() => _ProductCardSkeletonState();
}

class _ProductCardSkeletonState extends State<ProductCardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _opacity = Tween<double>(begin: 0.5, end: 1)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppTheme.radiusLarge);

    return FadeTransition(
      opacity: _opacity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: radius,
          boxShadow: AppTheme.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Column(
            children: [
              const AspectRatio(
                aspectRatio: ProductCard._imageAspectRatio,
                child: SizedBox.expand(
                  child: ColoredBox(color: AppTheme.border),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: ProductCard._infoPadding,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonBar(widthFactor: 0.9, height: 12),
                      SizedBox(height: AppTheme.spacingSm),
                      _SkeletonBar(widthFactor: 0.6, height: 12),
                      Spacer(),
                      _SkeletonBar(
                        widthFactor: 1,
                        height: AppTheme.buttonHeightCompact,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({required this.widthFactor, required this.height});

  final double widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppTheme.border,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
      ),
    );
  }
}