import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

@immutable
class AuthUser {
  final bool isVerified;
  const AuthUser(this.isVerified);
  factory AuthUser.fromFirebase(User user) => AuthUser(user.emailVerified);
}
