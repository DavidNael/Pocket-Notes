import 'package:bloc/bloc.dart';
import 'package:pocketnotes/Services/auth/Exceptions.dart';
import 'package:pocketnotes/Services/auth/Provider.dart';
import 'package:pocketnotes/Services/auth/bloc/auth_event.dart';
import 'package:pocketnotes/Services/auth/bloc/auth_state.dart';
import 'package:pocketnotes/utilities/dialogs/verification_dialog.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateUninitialized()) {
    ///Forgot Password
    on<AuthEventForgotpassword>(
      ((event, emit) async {
        emit(const AuthStateForgotPassword(
          exception: null,
          hasSentEmail: false,
          isLoading: true,
        ));
        final email = event.email;

        ///Just visiting the page
        if (email == null) {
          emit(const AuthStateForgotPassword(
            exception: null,
            hasSentEmail: false,
            isLoading: false,
          ));
        } else {
          ///User forgot password
          emit(const AuthStateForgotPassword(
              exception: null, hasSentEmail: false, isLoading: true));
          bool didSendPassword;
          Exception? exception;
          try {
            await provider.sendPasswordReset(toEmail: email);
            didSendPassword = true;
            exception = null;
          } on Exception catch (e) {
            didSendPassword = false;
            exception = e;
          }
          emit(AuthStateForgotPassword(
              exception: exception,
              hasSentEmail: didSendPassword,
              isLoading: false));
        }
      }),
    );

    ///Send Email Verification
    on<AuthEventSendEmailVerification>(((event, emit) async {
      if (event.sendEmail) {
        emit(const AuthStateNeedsVerification(
            isLoading: true, loadingText: 'Sending Email', exception: null));
        try {
          await provider.sendEmailVerification();
          emit(const AuthStateNeedsVerification(
              isLoading: false, exception: null));
        } on VerifyEmailException catch (e) {
          emit(AuthStateNeedsVerification(isLoading: false, exception: e));
        } on Exception catch (e) {
          emit(AuthStateNeedsVerification(isLoading: false, exception: e));
        }
      } else {
        emit(const AuthStateNeedsVerification(
            isLoading: false, exception: null));
      }
    }));

    ///Register
    on<AuthEventRegister>(((event, emit) async {
      final email = event.email;
      final password = event.password;
      emit(const AuthStateRegistering(
          exception: null, isLoading: true, loadingText: 'Registering...'));
      try {
        await provider.createUser(
          email: email,
          password: password,
        );
        emit(const AuthStateRegistering(exception: null, isLoading: false));
        await provider.sendEmailVerification();
      } on Exception catch (e) {
        emit(AuthStateRegistering(exception: e, isLoading: false));
      }
    }));

    ///Should Register
    on<AuthEventShouldRegister>(((event, emit) {
      emit(const AuthStateRegistering(exception: null, isLoading: false));
    }));

    ///Initialize
    on<AuthEventInitialize>(((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(
          const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          ),
        );
      } else if (user.isVerified != true) {
        emit(const AuthStateNeedsVerification(
            isLoading: false, exception: null));
      } else {
        emit(AuthStateLoggedIn(user, isLoading: false));
      }
    }));

    ///Login
    on<AuthEventLogIn>(((event, emit) async {
      emit(const AuthStateLoggedOut(
          exception: null, isLoading: true, loadingtext: 'Logging in...'));
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.login(email: email, password: password);
        if (user.isVerified != true) {
          emit(
            const AuthStateLoggedOut(
              exception: null,
              isLoading: false,
            ),
          );
          emit(const AuthStateNeedsVerification(
              isLoading: false, exception: null));
        } else {
          emit(
            const AuthStateLoggedOut(
              exception: null,
              isLoading: false,
            ),
          );
          emit(AuthStateLoggedIn(user, isLoading: false));
        }
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    }));

    ///Logout
    on<AuthEventLogOut>(((event, emit) async {
      emit(const AuthStateUninitialized());
      try {
        if (provider.currentUser == null) {
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
        } else {
          await provider.logout();
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
        }
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    }));
  }
}
