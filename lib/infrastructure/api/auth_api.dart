import 'package:dio/dio.dart';
import 'package:shopping_app/core/constants/api_constants.dart';
import 'package:shopping_app/core/constants/app_constants.dart';
import 'package:shopping_app/domain/auth_model/user_model.dart';
import 'package:shopping_app/infrastructure/api/api_client.dart';

/// Handles authentication against the DummyJSON /auth/login endpoint.
///
/// ⚠️  IMPORTANT — MOCK AUTHENTICATION NOTE:
/// DummyJSON's login endpoint requires a username (not an email address).
/// Our app UI accepts email for a professional UX, but internally we always
/// authenticate using the fixed demo credentials below.
///
/// This is intentional for an assessment/demo context.
/// In a real application you would validate the email against your own backend.
///
/// ENDPOINT:
///   POST /auth/login
///   Body: { "username": "...", "password": "...", "expiresInMins": 60 }
///   Response: { "id", "firstName", "lastName", "email", "username", "token", ... }
class AuthApi {
  AuthApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  /// Attempts login with the DummyJSON demo credentials.
  ///
  /// [emailInput] is what the user typed — it is validated for format in the
  /// UI, but we don't send it to DummyJSON (it doesn't accept emails).
  ///
  /// Returns a [UserModel] on success.
  /// Throws a [String] error message on failure.
  Future<UserModel> login({
    required String emailInput, // used only for UI validation, not sent to API
    required String passwordInput, // validated in UI; demo always uses fixed password
  }) async {
    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        ApiConstants.login,
        data: {
          // Fixed demo credentials — see AppConstants for explanation.
          'username': AppConstants.demoUsername,
          'password': AppConstants.demoPassword,
          'expiresInMins': 60,
        },
      );
      return UserModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  String _handleDioError(DioException e) {
    if (e.response?.statusCode == 400) {
      // DummyJSON returns 400 for wrong credentials.
      return 'Invalid credentials. Please try again.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'No internet connection. Please try again.';
    }
    return 'Login failed. Please try again.';
  }
}
