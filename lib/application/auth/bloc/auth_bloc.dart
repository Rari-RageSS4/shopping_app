import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shopping_app/application/auth/bloc/auth_event.dart';
import 'package:shopping_app/application/auth/bloc/auth_state.dart';
import 'package:shopping_app/domain/auth_model/user_model.dart';
import 'package:shopping_app/infrastructure/api/auth_api.dart';
import 'package:shopping_app/infrastructure/database/hive/hive_service.dart';

/// Manages authentication state for the entire application.
///
/// STATE MACHINE:
///   AuthInitial
///     ↓ CheckAuthStatus
///   AuthAuthenticated (if session found) OR AuthUnauthenticated (if not)
///
///   AuthUnauthenticated
///     ↓ LoginRequested
///   AuthLoading → AuthAuthenticated (success) OR AuthUnauthenticated(message) (failure)
///
///   AuthAuthenticated
///     ↓ LogoutRequested
///   AuthUnauthenticated
///
/// The router listens to this BLoC (see createAppRouter) to decide which
/// screen to show.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    AuthApi? authApi,
    HiveService? hiveService,
  })  : _authApi = authApi ?? AuthApi(),
        _hive = hiveService ?? HiveService.instance,
        super(const AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  final AuthApi _authApi;
  final HiveService _hive;

  // Hive session key — only AuthBloc reads/writes this.
  static const _sessionKey = 'user';

  // ── Session storage helpers ───────────────────────────────────────────────
  // The user is stored as a JSON *string*. Hive hands nested maps back as
  // Map<dynamic, dynamic>, which breaks fromJson casts; a JSON string always
  // round-trips to properly typed Map<String, dynamic>.

  Future<void> _saveSession(UserModel user) =>
      _hive.sessionBox.put(_sessionKey, jsonEncode(user.toJson()));

  /// Returns the saved user JSON, or null if nothing is saved.
  /// Also understands the older format (a raw Map) written by earlier builds.
  Map<String, dynamic>? _readSession() {
    final saved = _hive.sessionBox.get(_sessionKey);
    if (saved is String) {
      return jsonDecode(saved) as Map<String, dynamic>;
    }
    if (saved is Map) {
      // encode → decode deep-converts nested Map<dynamic, dynamic>.
      return jsonDecode(jsonEncode(saved)) as Map<String, dynamic>;
    }
    return null;
  }

  // ── CheckAuthStatus ───────────────────────────────────────────────────────

  /// Restores a previous session from Hive at app startup.
  ///
  /// Always ends in AuthAuthenticated or AuthUnauthenticated, so the router
  /// never gets stuck on the splash screen. The debugPrint lines show in the
  /// debug console and tell you exactly which path was taken.
  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    try {
      debugPrint(
        'AuthBloc: session box keys = ${_hive.sessionBox.keys.toList()}',
      );
      final json = _readSession();
      if (json != null) {
        final user = UserModel.fromJson(json);
        debugPrint('AuthBloc: saved session restored → Home');
        emit(AuthAuthenticated(user: user));
        return;
      }
      debugPrint('AuthBloc: no saved session found → Login');
    } catch (e, stackTrace) {
      debugPrint('AuthBloc: saved session could not be read → Login');
      debugPrint('AuthBloc: error = $e');
      debugPrint('AuthBloc: stack = $stackTrace');
      await _hive.sessionBox.delete(_sessionKey);
    }
    emit(const AuthUnauthenticated());
  }

  // ── LoginRequested ────────────────────────────────────────────────────────

  /// 1. Emits AuthLoading (shows spinner on the login button).
  /// 2. Calls AuthApi.login().
  /// 3. On success: saves the session to Hive, emits AuthAuthenticated.
  /// 4. On failure: emits AuthUnauthenticated with error message.
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final user = await _authApi.login(
        emailInput: event.email,
        passwordInput: event.password,
      );

      // Persist the session so the user stays logged in after app restart.
      await _saveSession(user);
      debugPrint(
        'AuthBloc: session saved, box keys = ${_hive.sessionBox.keys.toList()}',
      );

      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthUnauthenticated(message: e.toString()));
    }
  }

  // ── LogoutRequested ───────────────────────────────────────────────────────

  /// Clears the Hive session and returns to the unauthenticated state.
  /// The router redirects back to LoginPage.
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _hive.sessionBox.delete(_sessionKey);
    debugPrint('AuthBloc: session cleared');
    emit(const AuthUnauthenticated());
  }
}