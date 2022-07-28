import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocketnotes/Services/auth/Provider.dart';
import 'package:pocketnotes/Services/auth/User.dart';
import 'package:pocketnotes/Services/auth/Exceptions.dart';

class FireBaseProvider implements AuthProvider {
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else if (e.code == 'weak-password') {
        throw WeakPasswordAuthException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailExistsAuthException();
      } else {
        if (email == '' && password == '') {
          throw EmptyEmailPasswordAuthException();
        } else if (email == '') {
          throw EmptyEmailAuthException();
        } else if (password == '') {
          throw EmptyPasswordAuthException();
        } else {
          throw UnknownAuthException();
        }
      }
    } catch (_) {
      throw UnknownAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    }
    return null;
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else if (e.code == 'user-not-found') {
        throw UserNotFoundAuthException();
      } else if (e.code == 'wrong-password') {
        throw WrongPasswordAuthException();
      } else {
        if (email == '' && password == '') {
          throw EmptyEmailPasswordAuthException();
        } else if (email == '') {
          throw EmptyEmailAuthException();
        } else if (password == '') {
          throw EmptyPasswordAuthException();
        } else {
          throw UnknownAuthException();
        }
      }
    } catch (_) {
      throw UnknownAuthException();
    }
  }

  @override
  Future<void> logout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<AuthUser> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      user.sendEmailVerification();
    } else {
      throw UserNotLoggedInAuthException();
    }
    throw UnimplementedError();
  }
}
