import 'package:pocketnotes/Services/auth/user.dart';

abstract class AuthProvider {
  Future<void> initialize();
  AuthUser? get currentUser;
  Future<AuthUser> createUser({
    required String email,
    required String password,
  });
  Future<void> sendEmailVerification();
  Future<AuthUser> login({required String email, required String password});
  Future<void> logout();
  Future<void> sendPasswordReset({required String toEmail});
}
