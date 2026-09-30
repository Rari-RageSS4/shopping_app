import 'package:dio/dio.dart';
import 'package:shopping_app/core/constants/api_constants.dart';

/// Singleton Dio HTTP client configured for DummyJSON.
///
/// WHY DIO instead of the built-in `http` package?
/// - BaseOptions sets base URL + timeouts once, not per call.
/// - Interceptors let us log requests/responses in one place.
/// - Error handling is consistent across all API files.
///
/// HOW TO USE:
///   final client = ApiClient.instance;
///   final response = await client.get('/products', queryParameters: {...});
class ApiClient {
  ApiClient._();

  static final ApiClient _instance = ApiClient._();

  /// Access the singleton: ApiClient.instance
  static ApiClient get instance => _instance;

  late final Dio _dio = _buildDio();

  /// The raw Dio instance — used by API classes to make requests.
  Dio get dio => _dio;

  Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,

        // How long to wait for the server to accept the connection.
        connectTimeout: const Duration(seconds: 10),

        // How long to wait for the server to send data after connection.
        receiveTimeout: const Duration(seconds: 15),

        // DummyJSON returns JSON — tell Dio to expect it.
        responseType: ResponseType.json,

        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // ── Logging interceptor (debug builds only) ──────────────────────────────
    // Prints request URLs and error details to the console.
    // Remove or gate behind kDebugMode in production.
    dio.interceptors.add(
      LogInterceptor(
        requestBody: false, // keep logs concise
        responseBody: false,
        error: true,
        logPrint: (obj) => print('[API] $obj'), // ignore: avoid_print
      ),
    );

    return dio;
  }
}
