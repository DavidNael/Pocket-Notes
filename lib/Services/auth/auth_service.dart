import 'package:pocketnotes/Services/auth/provider.dart';
import 'package:pocketnotes/Services/auth/user.dart';
import 'package:pocketnotes/Services/auth/firebase_provider.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;
  const AuthService(this.provider);

  factory AuthService.firebase() => AuthService(FireBaseProvider());

  @override
  Future<AuthUser> createUser(
          {required String email, required String password}) =>
      provider.createUser(email: email, password: password);

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> login({required String email, required String password}) =>
      provider.login(email: email, password: password);

  @override
  Future<void> logout() => provider.logout();
  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();

  @override
  Future<void> initialize() => provider.initialize();

  @override
  Future<void> sendPasswordReset({required String toEmail}) =>
      provider.sendPasswordReset(toEmail: toEmail);
}
