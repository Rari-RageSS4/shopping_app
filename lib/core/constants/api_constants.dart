/// Central definition of all DummyJSON API endpoints and configuration.
///
/// Having all URLs in one place means:
/// - No magic strings scattered across API files
/// - Easy to swap the base URL for a different environment
/// - Instantly visible to anyone reading the architecture
library;

class ApiConstants {
  ApiConstants._(); // prevent instantiation

  // ── Base ────────────────────────────────────────────────────────────────────

  /// Root of the DummyJSON REST API.
  static const String baseUrl = 'https://dummyjson.com';

  // ── Products ────────────────────────────────────────────────────────────────

  /// GET /products?limit=&skip=&sortBy=&order=
  /// Returns a paginated list of all products.
  static const String products = '/products';

  /// GET /products/{id}
  /// Returns a single product by its numeric ID.
  static const String productById = '/products'; // append /{id}

  /// GET /products/search?q=&limit=&skip=
  /// Full-text search across product titles and descriptions.
  static const String productSearch = '/products/search';

  /// GET /products/category-list
  /// Returns a flat `List<String>` of all available category slugs.
  static const String categoryList = '/products/category-list';

  /// GET /products/category/{slug}?limit=&skip=
  /// Returns products filtered to a single category.
  static const String productsByCategory = '/products/category'; // append /{slug}

  // ── Auth ────────────────────────────────────────────────────────────────────

  /// POST /auth/login
  /// Body: { username, password, expiresInMins }
  /// Returns: { token, refreshToken, id, username, email, … }
  ///
  /// NOTE: DummyJSON uses 'username', not 'email'.
  /// Our login UI accepts email for UX, but we authenticate with a
  /// demo DummyJSON username behind the scenes (mock/assessment auth).
  static const String login = '/auth/login';

  // ── Pagination defaults ──────────────────────────────────────────────────────

  /// Number of products to fetch per page.
  /// 20 is a good balance: quick first load, clear infinite-scroll steps.
  static const int pageSize = 20;
}
