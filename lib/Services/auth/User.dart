import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

@immutable
class AuthUser {
  final String id;
  final bool isVerified;
  final String email;
  const AuthUser({
    required this.id,
    required this.email,
    required this.isVerified,
  });
  factory AuthUser.fromFirebase(User user) => AuthUser(
        isVerified: user.emailVerified,
        email: user.email!,
        id: user.uid,
      );
}
