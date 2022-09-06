import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pocketnotes/Services/auth/provider.dart';
import 'package:pocketnotes/Services/auth/user.dart';
import 'package:pocketnotes/Services/auth/exceptions.dart';

import '../../firebase_options.dart';

class FireBaseProvider implements AuthProvider {
  ///Register
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    bool validatePassword(String value) {
      RegExp regExp = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$');
      if (regExp.hasMatch(value)) {
        return true;
      } else {
        return false;
      }
    }

    try {
      if (!validatePassword(password) && password.isNotEmpty) {
        throw WeakPasswordAuthException();
      }
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
          throw UnknownException();
        }
      }
    } on WeakPasswordAuthException catch (_) {
      throw WeakPasswordAuthException();
    } catch (_) {
      throw UnknownException();
    }
  }

  ///User Getter
  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    }
    return null;
  }

  ///Login
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
          throw UnknownException();
        }
      }
    } catch (_) {
      throw UnknownException();
    }
  }

  ///Logout
  @override
  Future<void> logout() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  ///Send Email Verification
  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    try {
      if (user != null) {
        await user.sendEmailVerification();
        throw VerifyEmailException();
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on VerifyEmailException catch (e) {
      throw VerifyEmailException();
    } on Exception catch (e) {
      throw UnknownException();
    }
  }

  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  ///Reset Password
  @override
  Future<void> sendPasswordReset({required String toEmail}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: toEmail);
      throw ResetPasswordException();
    } on ResetPasswordException catch (e) {
      throw ResetPasswordException();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else if (e.code == 'user-not-found') {
        throw UserNotFoundAuthException();
      } else {
        if (toEmail.isEmpty) {
          throw EmptyEmailAuthException();
        } else {
          throw UnknownException();
        }
      }
    } catch (_) {
      throw UnknownException();
    }
  }
}
