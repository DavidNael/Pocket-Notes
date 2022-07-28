import 'package:pocketnotes/Services/auth/User.dart';

abstract class AuthProvider {
  AuthUser? get currentUser;
  Future<AuthUser> createUser({
    required String email,
    required String password,
  });
  Future<AuthUser> sendEmailVerification();
  Future<AuthUser> login({required String email, required String password});
  Future<void> logout();
}
