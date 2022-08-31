import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:pocketnotes/Services/auth/User.dart';

@immutable
abstract class AuthState {
  final bool isLoading;
  final String? loadingText;
  const AuthState({
    required this.isLoading,
    this.loadingText = 'loading...',
  });
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;
  const AuthStateRegistering(
      {required this.exception, required bool isLoading, String? loadingText})
      : super(isLoading: isLoading, loadingText: loadingText);
}

class AuthStateForgotPassword extends AuthState {
  final Exception? exception;
  final bool hasSentEmail;

  const AuthStateForgotPassword(
      {required this.exception,
      required this.hasSentEmail,
      required bool isLoading})
      : super(isLoading: isLoading);
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized() : super(isLoading: false);
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn(this.user, {required bool isLoading})
      : super(isLoading: isLoading);
}

class AuthStateNeedsVerification extends AuthState {
  final Exception? exception;
  const AuthStateNeedsVerification(
      {required bool isLoading, required this.exception, String? loadingText})
      : super(isLoading: isLoading, loadingText: loadingText);
}

class AuthStateLoggedOut extends AuthState with EquatableMixin {
  final Exception? exception;
  const AuthStateLoggedOut(
      {required this.exception, required bool isLoading, String? loadingtext})
      : super(isLoading: isLoading, loadingText: loadingtext);

  @override
  List<Object?> get props => [exception, isLoading];
}
