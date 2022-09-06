import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketnotes/Services/auth/bloc/auth_bloc.dart';
import 'package:pocketnotes/Services/auth/bloc/auth_event.dart';
import 'package:pocketnotes/Services/auth/bloc/auth_state.dart';
import 'package:pocketnotes/utilities/dialogs/loading_dialog.dart';
import 'package:pocketnotes/views/login_signup.dart';
import 'package:pocketnotes/views/Notes/notes_view.dart';
import 'package:pocketnotes/views/verify_email_view.dart';
import 'package:pocketnotes/views/forgot_password.dart';
import 'package:pocketnotes/views/welcome_page.dart';
import 'Constants/Widgets.dart';

class ControllerView extends StatefulWidget {
  const ControllerView({Key? key}) : super(key: key);

  @override
  State<ControllerView> createState() => _ControllerViewState();
}

class _ControllerViewState extends State<ControllerView> {
  @override
  Widget build(BuildContext context) {
    CloseDialog? closeDialogHandle;
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) async {
        final closeDialog = closeDialogHandle;
        if (!state.isLoading && closeDialog != null) {
          closeDialog();
          closeDialogHandle = null;
        } else if (state.isLoading && closeDialog == null) {
          closeDialogHandle = ShowLoadingDialog(
              context: context, text: state.loadingText ?? 'Loading...');
        }
      },
      builder: (context, state) {
        if (state is AuthStateFirstLaunch) {
          return const WelcomePage();
        } else if (state is AuthStateLoggedIn) {
          return const NotesView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateForgotPassword) {
          return const ForgotPasswordView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginSignupView();
        } else if (state is AuthStateUninitialized) {
          return loadingWidget;
        } else if (state is AuthStateRegistering) {
          return const LoginSignupView();
        } else {
          return const Scaffold(
            body: Text('Error Loading App....'),
          );
        }
      },
    );
  }
}
