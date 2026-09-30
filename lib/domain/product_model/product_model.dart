/// ProductModel — represents a single product from the DummyJSON API.
///
/// DATA FLOW:
///   DummyJSON API → JSON Map → ProductModel.fromJson() → BLoC state → Widget
///
/// API FIELD MAPPINGS (from /products and /products/search responses):
///   "id"                 → id
///   "title"              → title        (product name)
///   "description"        → description
///   "price"              → price        (USD, double)
///   "discountPercentage" → discountPercentage
///   "rating"             → rating       (0.0 – 5.0)
///   "stock"              → stock        (units available)
///   "brand"              → brand        (nullable — not all products have a brand)
///   "category"           → category     (slug string, e.g. "smartphones")
///   "thumbnail"          → thumbnail    (single image URL used in list/card)
///   "images"             → images       (list of image URLs used in detail page)
class ProductModel {
  const ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    this.brand,
    required this.category,
    required this.thumbnail,
    required this.images,
  });

  final int id;
  final String title;
  final String description;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String? brand; // nullable — API omits this field for some products
  final String category;
  final String thumbnail; // used in product cards
  final List<String> images; // used in product detail gallery

  // ── Computed helpers ──────────────────────────────────────────────────────

  /// Price after applying the discount percentage.
  double get discountedPrice =>
      price - (price * discountPercentage / 100);

  /// True when at least 1 unit is in stock.
  bool get isInStock => stock > 0;

  // ── Deserialization ───────────────────────────────────────────────────────

  /// Builds a ProductModel from the JSON object returned by the DummyJSON API.
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      discountPercentage: (json['discountPercentage'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      stock: json['stock'] as int,
      brand: json['brand'] as String?, // nullable
      category: json['category'] as String,
      thumbnail: json['thumbnail'] as String,
      images: List<String>.from(json['images'] as List),
    );
  }

  /// Converts this model back to a Map (used when storing in Hive cache).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'stock': stock,
      'brand': brand,
      'category': category,
      'thumbnail': thumbnail,
      'images': images,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is ProductModel && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ProductModel(id: $id, title: $title)';
}

/// Wraps the paginated products API response.
///
/// The DummyJSON products endpoint always returns:
///   { "products": [...], "total": 194, "skip": 0, "limit": 20 }
///
/// We need `total` to know when we've loaded all available products
/// (i.e., when skip + limit >= total → no more pages).
class ProductsResponse {
  const ProductsResponse({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  final List<ProductModel> products;
  final int total; // total products available in DummyJSON
  final int skip;  // how many were skipped (current offset)
  final int limit; // how many were requested

  /// Builds from the raw API JSON map.
  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    return ProductsResponse(
      products: (json['products'] as List)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      skip: json['skip'] as int,
      limit: json['limit'] as int,
    );
  }
}
