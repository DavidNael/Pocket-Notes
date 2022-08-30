import 'package:bloc/bloc.dart';
import 'package:pocketnotes/Services/auth/Provider.dart';
import 'package:pocketnotes/Services/auth/bloc/auth_event.dart';
import 'package:pocketnotes/Services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateLoading()) {
    ///Initialize
    on<AuthEventInitialize>(((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut(null));
      } else if (user.isVerified != true) {
        emit(const AuthStateNeedsVerefication());
      } else {
        emit(AuthStateLoggedIn(user));
      }
    }));

    ///Login
    on<AuthEventLogIn>(((event, emit) async {
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.login(email: email, password: password);
        emit(const AuthStateLoading());
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(e));
      }
    }));

    ///Logout
    on<AuthEventLogOut>(((event, emit) async {
      emit(const AuthStateLoading());
      try {
        await provider.logout();
        emit(const AuthStateLoggedOut(null));
      } on Exception catch (e) {
        emit(AuthStateLogoutFailure(e));
      }
    }));
  }
}
