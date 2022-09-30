import 'package:flutter/cupertino.dart';

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventWelcome extends AuthEvent {
  const AuthEventWelcome();
}

class AuthEventLogIn extends AuthEvent {
  final String email;
  final String password;

  const AuthEventLogIn(this.email, this.password);
}

class AuthEventLogOut extends AuthEvent {
  const AuthEventLogOut();
}

class AuthEventSendEmailVerification extends AuthEvent {
  final bool sendEmail;
  const AuthEventSendEmailVerification({required this.sendEmail});
}

class AuthEventRegister extends AuthEvent {
  final String username;
  final String email;
  final String password;
  const AuthEventRegister(this.email, this.password, this.username);
}

class AuthEventShouldRegister extends AuthEvent {
  const AuthEventShouldRegister();
}

class AuthEventForgotpassword extends AuthEvent {
  final String? email;
  const AuthEventForgotpassword(this.email);
}
