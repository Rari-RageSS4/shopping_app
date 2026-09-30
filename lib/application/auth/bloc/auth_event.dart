import 'package:equatable/equatable.dart';

/// All possible events the AuthBloc can receive.
///
/// HOW EVENTS WORK:
/// A widget dispatches an event: `context.read<AuthBloc>().add(LoginRequested(...))` 
/// The BLoC's event handler maps each event to a state transition.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when the user taps the login button.
///
/// [email] is what the user typed (used for UI display only).
/// [password] is what the user typed (validated in LoginPage before dispatch).
///
/// The AuthBloc passes these to AuthApi, which handles the demo auth logic.
class LoginRequested extends AuthEvent {
  const LoginRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Dispatched when the user taps "Log out".
/// The BLoC clears the Hive session box and returns to AuthInitial.
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Dispatched at app startup to check whether a session already exists in Hive.
/// If a saved user is found, the BLoC emits AuthAuthenticated without login.
class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}
