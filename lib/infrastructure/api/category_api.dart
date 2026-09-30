import 'package:dio/dio.dart';
import 'package:shopping_app/core/constants/api_constants.dart';
import 'package:shopping_app/domain/category_model/category_model.dart';
import 'package:shopping_app/infrastructure/api/api_client.dart';

/// Fetches the product category list from DummyJSON.
///
/// ENDPOINT:
///   GET /products/category-list
///   Returns a flat `List<String>` of category slug strings, e.g.:
///   ["beauty", "fragrances", "furniture", "groceries", "skin-care", ...]
///
/// We convert each raw slug into a [CategoryModel] so the UI gets
/// a display-ready name without any transformation logic in widgets.
class CategoryApi {
  CategoryApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  /// Fetches all available product categories.
  ///
  /// Returns a list of [CategoryModel] objects, sorted alphabetically
  /// so the UI category row is predictable.
  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final response = await _client.dio.get<List<dynamic>>(
        ApiConstants.categoryList,
      );

      // The API returns List<dynamic> of raw strings — cast and map to models.
      final slugs = response.data!.cast<String>();
      final categories = slugs
          .map(CategoryModel.fromSlug)
          .toList()
        ..sort((a, b) => a.displayName.compareTo(b.displayName));

      return categories;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  String _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError) {
      return 'No internet connection. Please try again.';
    }
    return 'Failed to load categories. Please try again.';
  }
}
