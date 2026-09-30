import 'package:dio/dio.dart';
import 'package:shopping_app/core/constants/api_constants.dart';
import 'package:shopping_app/domain/product_model/product_model.dart';
import 'package:shopping_app/infrastructure/api/api_client.dart';

/// All DummyJSON product-related API calls live here.
///
/// This class is the single place where:
///   - Endpoint paths are used
///   - Query parameters are assembled
///   - Raw JSON is converted to domain models
///
/// The BLoC calls this class — never calls Dio directly.
///
/// ENDPOINTS USED:
///   GET /products               → fetchProducts()
///   GET /products/{id}          → fetchProductById()
///   GET /products/search        → searchProducts()
///   GET /products/category/{slug} → fetchProductsByCategory()
class ProductApi {
  ProductApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  // ── Fetch paginated products ──────────────────────────────────────────────

  /// Fetches a page of products from GET /products.
  ///
  /// PAGINATION:
  ///   [skip] is the offset — how many products to skip.
  ///   [limit] is the page size — how many to return.
  ///   Example: skip=0, limit=20 → first page; skip=20, limit=20 → second page.
  ///
  /// SORTING:
  ///   [sortBy] accepts DummyJSON field names: "price", "rating", "title".
  ///   [order] is "asc" or "desc".
  ///
  /// Returns a [ProductsResponse] which includes `total` — needed to detect
  /// when all available products have been loaded (end of infinite scroll).
  Future<ProductsResponse> fetchProducts({
    int skip = 0,
    int limit = ApiConstants.pageSize,
    String? sortBy,
    String? order,
  }) async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        ApiConstants.products,
        queryParameters: {
          'limit': limit,
          'skip': skip,
          // Only include sort params when provided.
          'sortBy': sortBy,
          'order': order,
        }..removeWhere((_, v) => v == null),
      );
      return ProductsResponse.fromJson(response.data!);
    } on DioException catch (e) {
      // Convert Dio-specific exceptions to a plain string message.
      // The BLoC catches this and emits an error state with the message.
      throw _handleDioError(e);
    }
  }

  // ── Fetch single product ──────────────────────────────────────────────────

  /// Fetches one product by its ID from GET /products/{id}.
  ///
  /// Used when the product detail page needs fresh data.
  /// (In practice we usually pass the product via navigation `extra`,
  ///  but this method is available if a deep-link requires a fresh fetch.)
  Future<ProductModel> fetchProductById(int id) async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        '${ApiConstants.productById}/$id',
      );
      return ProductModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ── Search products ───────────────────────────────────────────────────────

  /// Searches products by query string from GET /products/search?q=.
  ///
  /// Supports the same limit/skip pagination as fetchProducts.
  /// The BLoC debounces calls to this method so the API is not
  /// hit on every keystroke.
  Future<ProductsResponse> searchProducts({
    required String query,
    int skip = 0,
    int limit = ApiConstants.pageSize,
  }) async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        ApiConstants.productSearch,
        queryParameters: {
          'q': query,
          'limit': limit,
          'skip': skip,
        },
      );
      return ProductsResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ── Products by category ──────────────────────────────────────────────────

  /// Fetches products filtered to a category from GET /products/category/{slug}.
  ///
  /// [categorySlug] is the raw API slug (e.g. "skin-care", "smartphones").
  /// Supports limit/skip pagination.
  Future<ProductsResponse> fetchProductsByCategory({
    required String categorySlug,
    int skip = 0,
    int limit = ApiConstants.pageSize,
  }) async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>(
        '${ApiConstants.productsByCategory}/$categorySlug',
        queryParameters: {
          'limit': limit,
          'skip': skip,
        },
      );
      return ProductsResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ── Error handling ────────────────────────────────────────────────────────

  /// Converts a DioException into a human-readable error message.
  ///
  /// This keeps error-handling logic in one place — the BLoC simply
  /// catches a String and puts it in the error state.
  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please check your internet connection.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please try again.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 404) return 'Product not found.';
        if (statusCode != null && statusCode >= 500) {
          return 'Server error ($statusCode). Please try again later.';
        }
        return 'Unexpected response from server.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
