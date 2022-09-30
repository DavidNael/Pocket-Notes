import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketnotes/Services/auth/bloc/auth_bloc.dart';
import 'package:pocketnotes/Services/auth/bloc/auth_event.dart';
import 'package:pocketnotes/Services/auth/bloc/auth_state.dart';
import 'package:pocketnotes/utilities/dialogs/loading_dialog.dart';
import 'package:pocketnotes/views/Constants/app_theme.dart';
import 'package:pocketnotes/views/login_signup.dart';
import 'package:pocketnotes/views/Notes/notes_view.dart';
import 'package:pocketnotes/views/verify_email_view.dart';
import 'package:pocketnotes/views/forgot_password.dart';
import 'package:pocketnotes/views/welcome_page.dart';
import 'package:provider/provider.dart';

class ControllerView extends StatefulWidget {
  const ControllerView({Key? key}) : super(key: key);

  @override
  State<ControllerView> createState() => _ControllerViewState();
}

class _ControllerViewState extends State<ControllerView> {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<AppTheme>(context).darkMode;

    CloseDialog? closeDialogHandle;
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) async {
        final closeDialog = closeDialogHandle;
        if (!state.isLoading && closeDialog != null) {
          closeDialog();
          closeDialogHandle = null;
        } else if (state.isLoading && closeDialog == null) {
          closeDialogHandle = showLoadingDialog(
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
          return Scaffold(
            backgroundColor: isDarkMode ? darkBorderTheme : lightBorderTheme,
            body: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Loading...',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  CircularProgressIndicator(),
                ],
              ),
            ),
          );
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
