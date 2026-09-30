import 'package:hive_flutter/hive_flutter.dart';
import 'package:shopping_app/core/constants/app_constants.dart';

/// Provides typed access to the Hive boxes opened at app startup.
///
/// WHY A SERVICE CLASS?
/// Instead of calling Hive.box('name') scattered across the codebase,
/// all box access goes through this class. This means:
/// - Box names are never duplicated — they come from AppConstants.
/// - Easier to swap or mock in tests.
/// - Clear documentation of what each box stores.
///
/// Hive boxes are already opened in main() before runApp(),
/// so these getters will always find an open box.
class HiveService {
  HiveService._();

  static final HiveService instance = HiveService._();

  // ── Product cache box ─────────────────────────────────────────────────────
  // Stores: first-page product list as JSON + a timestamp for TTL checks.
  // Key layout:
  //   'products'  → List<Map<String, dynamic>> (serialised ProductModel list)
  //   'timestamp' → int (milliseconds since epoch of last write)

  /// Opens the product cache box (must already be opened in main()).
  Box<dynamic> get productCacheBox =>
      Hive.box<dynamic>(AppConstants.productCacheBox);

  // ── Session box ───────────────────────────────────────────────────────────
  // Stores: the logged-in user's serialised UserModel.
  // Key layout:
  //   'user' → Map<String, dynamic> (serialised UserModel)

  /// Opens the session box (must already be opened in main()).
  Box<dynamic> get sessionBox =>
      Hive.box<dynamic>(AppConstants.sessionBox);
}
