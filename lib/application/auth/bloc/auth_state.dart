import 'package:equatable/equatable.dart';
import 'package:shopping_app/domain/auth_model/user_model.dart';

/// All possible states the AuthBloc can emit.
///
/// HOW STATES WORK:
/// Widgets listen to the BLoC stream and rebuild when a new state is emitted.
/// Each state is a separate class (not an enum) so it can carry typed data.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state — the BLoC has not yet checked for a saved session.
/// The router shows a splash/loading screen at this point.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// A login request or session check is in progress.
/// The login button shows a loading indicator in this state.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// The user is authenticated.
/// [user] holds the UserModel returned by the API (or restored from Hive).
/// The router redirects to HomePage in this state.
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.user});

  final UserModel user;

  @override
  List<Object?> get props => [user];
}

/// The user is not authenticated (login failed or logged out).
/// [message] is shown as an error in the login form (can be null on initial load).
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({this.message});

  final String? message; // null = not logged in yet; non-null = login error

  @override
  List<Object?> get props => [message];
}
