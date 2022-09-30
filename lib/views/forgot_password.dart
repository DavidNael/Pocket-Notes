import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketnotes/Services/auth/exceptions.dart';
import 'package:pocketnotes/Services/auth/bloc/auth_bloc.dart';
import 'package:pocketnotes/Services/auth/bloc/auth_event.dart';
import 'package:pocketnotes/Services/auth/bloc/auth_state.dart';
import 'package:pocketnotes/utilities/dialogs/error_dialog.dart';
import 'package:pocketnotes/utilities/dialogs/password_reset_dialog.dart';
import 'package:provider/provider.dart';

import 'Constants/app_theme.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color themeColor =
        Provider.of<AppTheme>(context, listen: false).getColorTheme();
    bool isDarkMode = Provider.of<AppTheme>(context).darkMode;
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context,
                'The email you\'ve typed is invalid, please check your email and try again.');
          } else if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(context,
                'The email you\'ve typed doesn\'t exist, please check your email and try again.');
          } else if (state.exception is ResetPasswordException) {
            final verifyDialog = await showPasswordResetDialog(context);
            if (verifyDialog) {
              context.read<AuthBloc>().add(const AuthEventLogOut());
            }
          } else if (state.exception is EmptyEmailAuthException) {
            await showErrorDialog(context, 'Email field can\'t be empty');
          } else if (state.exception != null) {
            await showErrorDialog(context,
                'Unknown error, Make sure you are connected to the internet and try again.');
          }
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          context.read<AuthBloc>().add(const AuthEventLogOut());
          return false;
        },
        child: Scaffold(
          backgroundColor: themeColor,
          appBar: AppBar(
            backgroundColor: isDarkMode ? darkBorderTheme : lightBorderTheme,
            foregroundColor: isDarkMode ? darkTextTheme : lightTextTheme,
            leading: BackButton(
              onPressed: () {
                context.read<AuthBloc>().add(const AuthEventLogOut());
              },
            ),
            title: const Text('Forgot Password'),
          ),
          body: Center(
            child: SingleChildScrollView(
              child: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color:
                              isDarkMode ? darkBorderTheme : lightBorderTheme,
                          border: Border.all(color: Colors.black)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),

                          ///Login Text
                          Container(
                            padding: const EdgeInsets.only(bottom: 50),
                            child: Text(
                              'Reset Password',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode
                                    ? darkHeaderTheme
                                    : lightHeaderTheme,
                              ),
                            ),
                          ),

                          //!E-mail Field
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? darkBorderTheme
                                  : lightBorderTheme,
                            ),
                            child: TextField(
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(
                                color:
                                    isDarkMode ? darkTextTheme : lightTextTheme,
                              ),
                              controller: _controller,
                              enableSuggestions: false,
                              autocorrect: false,
                              textAlign: TextAlign.start,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),
                                labelText: 'Email:',
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? darkTextTheme
                                      : lightTextTheme,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: isDarkMode
                                        ? darkTextTheme
                                        : lightTextTheme,
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: themeColor,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 10.0,
                          ),

                          //! Reset Button
                          Container(
                            padding: const EdgeInsets.all(20),
                            child: SizedBox(
                              width: 250,
                              height: 60,
                              child: TextButton(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.0))),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          themeColor),
                                ),
                                onPressed: () async {
                                  final email = _controller.text;
                                  context.read<AuthBloc>().add(
                                        AuthEventForgotpassword(email),
                                      );
                                },
                                child: const Text(
                                  'Reset Password',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
