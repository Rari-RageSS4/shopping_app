import 'package:shopping_app/core/constants/app_constants.dart';
import 'package:shopping_app/domain/product_model/product_model.dart';
import 'package:shopping_app/infrastructure/database/hive/hive_service.dart';

/// Handles reading and writing the first-page product cache in Hive.
///
/// CACHING STRATEGY:
/// Only the first page of products is cached. This gives the app a fast
/// startup display while fresh data is fetched in the background.
/// Pages 2, 3, ... (infinite scroll) are never cached — they are ephemeral.
///
/// CACHE KEYS (in AppConstants.productCacheBox):
///   'products'  → `List<dynamic>` — serialised product JSON maps
///   'timestamp' → int           — epoch ms of when the cache was written
///
/// TTL:
///   Cache is valid for AppConstants.cacheValidMinutes (10 minutes).
///   After that, fresh data is fetched from the API.
class ProductCache {
  ProductCache({HiveService? hiveService})
      : _hive = hiveService ?? HiveService.instance;

  final HiveService _hive;

  // Hive key constants — only this class uses them.
  static const _keyProducts = 'products';
  static const _keyTimestamp = 'timestamp';

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Returns cached products if the cache exists and is still valid.
  /// Returns null if the cache is empty or expired.
  List<ProductModel>? getCachedProducts() {
    final box = _hive.productCacheBox;
    final rawList = box.get(_keyProducts) as List<dynamic>?;
    final timestamp = box.get(_keyTimestamp) as int?;

    // No cache stored yet.
    if (rawList == null || timestamp == null) return null;

    // Check TTL — is the cache still fresh?
    final cachedAt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final age = DateTime.now().difference(cachedAt);
    if (age.inMinutes >= AppConstants.cacheValidMinutes) {
      // Cache has expired — caller should fetch fresh data.
      return null;
    }

    // Deserialise each stored JSON map back into a ProductModel.
    return rawList
        .cast<Map<dynamic, dynamic>>()
        .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Saves [products] to the Hive cache, recording the current timestamp.
  /// This overwrites any previously cached data.
  Future<void> cacheProducts(List<ProductModel> products) async {
    final box = _hive.productCacheBox;
    // Serialise each ProductModel to a Map so Hive can store it.
    final serialised = products.map((p) => p.toJson()).toList();
    await box.put(_keyProducts, serialised);
    await box.put(_keyTimestamp, DateTime.now().millisecondsSinceEpoch);
  }

  // ── Clear ─────────────────────────────────────────────────────────────────

  /// Clears the entire product cache.
  /// Call this when the user logs out or when a force-refresh is needed.
  Future<void> clearCache() async {
    await _hive.productCacheBox.clear();
  }
}
