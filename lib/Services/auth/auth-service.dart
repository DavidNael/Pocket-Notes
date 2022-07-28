import 'package:pocketnotes/Services/auth/Provider.dart';
import 'package:pocketnotes/Services/auth/User.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;

  AuthService(this.provider);

  @override
  Future<AuthUser> createUser(
          {required String email, required String password}) =>
      provider.createUser(email: email, password: password);

  @override
  // TODO: implement currentUser
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> login({required String email, required String password}) =>
      provider.login(email: email, password: password);

  @override
  Future<void> logout() => provider.logout();
  @override
  Future<AuthUser> sendEmailVerification() => provider.sendEmailVerification();
}
