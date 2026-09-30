import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:shopping_app/application/auth/bloc/auth_bloc.dart';
import 'package:shopping_app/application/auth/bloc/auth_event.dart';
import 'package:shopping_app/application/cart/bloc/cart_bloc.dart';
import 'package:shopping_app/application/category/bloc/category_bloc.dart';
import 'package:shopping_app/application/product/bloc/product_bloc.dart';
import 'package:shopping_app/core/constants/app_constants.dart';
import 'package:shopping_app/core/routes/app_router.dart';
import 'package:shopping_app/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Hive before the application starts.
  await Hive.initFlutter();

  // Open local cache boxes used by the application.
  await Hive.openBox<dynamic>(AppConstants.productCacheBox);
  await Hive.openBox<dynamic>(AppConstants.sessionBox);

  runApp(const ShoppingApp());
}

class ShoppingApp extends StatefulWidget {
  const ShoppingApp({super.key});

  @override
  State<ShoppingApp> createState() => _ShoppingAppState();
}

class _ShoppingAppState extends State<ShoppingApp> {
  // AuthBloc and the router are created together so the router can react to
  // the session check that starts immediately below.
  late final AuthBloc _authBloc;
  late final AuthRefreshNotifier _authRefresh;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc();
    _authRefresh = AuthRefreshNotifier(_authBloc.stream);
    _router = createAppRouter(
      authBloc: _authBloc,
      refreshListenable: _authRefresh,
    );
    // Restore the saved Hive session. The router redirects once it finishes.
    _authBloc.add(const CheckAuthStatus());
  }

  @override
  void dispose() {
    _router.dispose();
    _authRefresh.dispose();
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<ProductBloc>(create: (_) => ProductBloc()),
        BlocProvider<CategoryBloc>(create: (_) => CategoryBloc()),
        BlocProvider<CartBloc>(create: (_) => CartBloc()),
      ],
      child: MaterialApp.router(
        title: 'ShopZen',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}