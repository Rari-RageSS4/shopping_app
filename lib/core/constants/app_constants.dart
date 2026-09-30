/// Application-wide non-API constants.
///
/// Spacing, animation durations, Hive box names, and other values
/// that are used across many files belong here so they stay consistent.
library;

class AppConstants {
  AppConstants._();

  // ── Hive box names ───────────────────────────────────────────────────────────
  // Each Hive box is a lightweight key-value store.
  // We use separate boxes so each concern is isolated.

  /// Stores the serialised first-page product list for quick startup display.
  static const String productCacheBox = 'product_cache';

  /// Stores the logged-in user's token and basic info between sessions.
  static const String sessionBox = 'session';

  // ── Cache TTL ────────────────────────────────────────────────────────────────

  /// How long (in minutes) the cached first-page products are considered fresh.
  /// After this time the app fetches new data from the API.
  static const int cacheValidMinutes = 10;

  // ── Search ───────────────────────────────────────────────────────────────────

  /// Milliseconds to wait after the user stops typing before firing a search.
  /// Prevents a new API request on every keystroke.
  static const int searchDebounceMsec = 500;

  // ── Infinite scroll ──────────────────────────────────────────────────────────

  /// Fraction of scroll extent at which we trigger the next page load.
  /// 0.9 = trigger when 90% of the list has been scrolled.
  static const double scrollTriggerFraction = 0.9;

  // ── Demo auth credentials ────────────────────────────────────────────────────
  // DummyJSON requires a username (not an email) for its /auth/login endpoint.
  // Our UI accepts an email for good UX, but internally we send these
  // hardcoded demo credentials — this is intentional mock/assessment behaviour.

  /// Fixed DummyJSON demo username used for all login attempts.
  static const String demoUsername = 'emilys';

  /// Fixed DummyJSON demo password.
  static const String demoPassword = 'emilyspass';
}
