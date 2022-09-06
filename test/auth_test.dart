import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pocketnotes/Services/auth/exceptions.dart';
import 'package:pocketnotes/Services/auth/provider.dart';
import 'package:pocketnotes/Services/auth/user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test('shouldnt be initialized', () {
      expect(provider.isInitialized, false);
    });
    test('cannot logout if not logged in', () {
      expect(provider.logout(),
          throwsA(const TypeMatcher<NotInitializedException>()));
    });
    test('should be initialized', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });
    test('should be no user', () {
      expect(provider.currentUser, null);
    });
    test('should be less than 2 seconds', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));
    test('create user should delegate login', () async {
      final badEmailUser = provider.createUser(
          email: 'davidnael824@gmail.com', password: '12345678');

      expect(badEmailUser,
          throwsA(const TypeMatcher<UserNotFoundAuthException>()));
      final badPasswordUser =
          provider.createUser(email: 'dadada@gmail.com', password: 'david');

      expect(badPasswordUser,
          throwsA(const TypeMatcher<WrongPasswordAuthException>()));
      final user = await provider.createUser(email: 'david', password: 'nael');
      expect(provider.currentUser, user);
      expect(user.isVerified, false);
    });
    test('user should be able to get verified', () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isVerified, true);
    });
    test('should be able to log in and out', () async {
      await provider.logout();
      await provider.login(email: 'email', password: 'password');
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser(
      {required String email, required String password}) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return login(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> login({required String email, required String password}) {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'davidnael824@gmail.com') throw UserNotFoundAuthException();
    if (password == 'david') throw WrongPasswordAuthException();
    const user =
        AuthUser(isVerified: false, email: 'david@gmail.com', id: 'my idd');
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logout() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user == null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser =
        AuthUser(isVerified: true, email: 'davidnael824@gmail.com', id: 'myId');
    _user = newUser;
  }

  @override
  Future<void> sendPasswordReset({required String toEmail}) {
    // TODO: implement sendPasswordReset
    throw UnimplementedError();
  }
}
