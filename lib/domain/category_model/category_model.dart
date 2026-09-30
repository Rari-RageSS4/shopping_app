/// CategoryModel — represents a single product category.
///
/// DATA FLOW:
///   GET /products/category-list → `List<String>` slugs
///   → CategoryModel.fromSlug()  → BLoC state → Widget
///
/// The DummyJSON category-list endpoint returns raw strings like:
///   ["beauty", "fragrances", "furniture", "groceries", ...]
///
/// We wrap each string in a CategoryModel so the UI has a display-ready name.
class CategoryModel {
  const CategoryModel({
    required this.slug,
    required this.displayName,
  });

  /// The raw API slug — used as the URL path segment.
  /// Example: "skin-care" (used in /products/category/skin-care)
  final String slug;

  /// Human-readable label shown in the UI.
  /// Example: "Skin Care" (converted from slug by capitalising words)
  final String displayName;

  /// Creates a CategoryModel from a raw DummyJSON category slug string.
  factory CategoryModel.fromSlug(String slug) {
    return CategoryModel(
      slug: slug,
      displayName: _slugToDisplayName(slug),
    );
  }

  /// Converts a kebab-case slug to Title Case for display.
  /// Example: "skin-care" → "Skin Care"
  static String _slugToDisplayName(String slug) {
    return slug
        .split('-')
        .map((word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryModel && other.slug == slug);

  @override
  int get hashCode => slug.hashCode;

  @override
  String toString() => 'CategoryModel(slug: $slug)';
}
