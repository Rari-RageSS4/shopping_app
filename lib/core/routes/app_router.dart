import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shopping_app/application/auth/bloc/auth_bloc.dart';
import 'package:shopping_app/application/auth/bloc/auth_state.dart';
import 'package:shopping_app/domain/product_model/product_model.dart';
import 'package:shopping_app/presentation/pages/cart/cart_page.dart';
import 'package:shopping_app/presentation/pages/home/home_page.dart';
import 'package:shopping_app/presentation/pages/login/login_page.dart';
import 'package:shopping_app/presentation/pages/product_detail/product_detail_page.dart';
import 'package:shopping_app/presentation/widgets/loading_indicator.dart';

/// Named route constants.
///
/// Using constants prevents typo bugs and makes navigation calls readable:
///   context.pushNamed(AppRoutes.productDetail, extra: product)
class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String productDetail = 'product-detail'; // child of home
  static const String cart = 'cart'; // child of home
}

/// Tells GoRouter to re-run its redirect whenever AuthBloc emits a new state.
class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier(Stream<AuthState> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Decides where the user should be, based purely on the auth state.
///
///   AuthInitial        → splash (session check still running)
///   AuthAuthenticated  → home (never show splash/login to a logged-in user)
///   anything else      → login
///
/// Returning null means "stay where you are".
String? _redirect(AuthState auth, String location) {
  final onSplash = location == AppRoutes.splash;
  final onLogin = location == AppRoutes.login;

  if (auth is AuthInitial) return onSplash ? null : AppRoutes.splash;
  if (auth is AuthAuthenticated) {
    return (onSplash || onLogin) ? AppRoutes.home : null;
  }
  return onLogin ? null : AppRoutes.login;
}

/// Application router built with GoRouter.
///
/// The router is driven by [AuthBloc]: startup restores the Hive session
/// (CheckAuthStatus), login/logout change the auth state, and [_redirect]
/// moves the user to the right screen. No screen navigates on its own.
///
/// NAVIGATION FLOW:
///   /splash → /login | /home
///   /home → /home/product-detail
///         → /home/cart
GoRouter createAppRouter({
  required AuthBloc authBloc,
  required Listenable refreshListenable,
}) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    refreshListenable: refreshListenable,
    redirect: (context, state) =>
        _redirect(authBloc.state, state.matchedLocation),
    routes: [
      // ── Splash (shown only while the saved session is being checked) ───────
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splash,
        builder: (context, state) => const Scaffold(body: LoadingIndicator()),
      ),

      // ── Login ──────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),

      // ── Home shell ─────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.home,
        name: AppRoutes.home,
        builder: (context, state) => const HomePage(),
        routes: [
          // We pass the full ProductModel via `extra` to avoid an API call.
          GoRoute(
            path: AppRoutes.productDetail,
            name: AppRoutes.productDetail,
            builder: (context, state) {
              final product = state.extra! as ProductModel;
              return ProductDetailPage(product: product);
            },
          ),
          GoRoute(
            path: AppRoutes.cart,
            name: AppRoutes.cart,
            builder: (context, state) => const CartPage(),
          ),
        ],
      ),
    ],
  );
}