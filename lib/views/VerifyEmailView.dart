import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketnotes/Services/auth/Exceptions.dart';
import 'package:pocketnotes/Services/auth/auth-service.dart';
import 'package:pocketnotes/Services/auth/bloc/auth_event.dart';
import 'package:pocketnotes/views/Constants/Routes.dart';
import '../Services/auth/bloc/auth_bloc.dart';
import '../Services/auth/bloc/auth_state.dart';
import '../firebase_options.dart';
import '../utilities/dialogs/verification_dialog.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);
  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateNeedsVerification) {
          if (state.exception is VerifyEmailException) {
            final verifyDialog = await showVerificationDialog(context);
            if (verifyDialog) {
              context.read<AuthBloc>().add(const AuthEventLogOut());
            }
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Verify Email')),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ///Page Description
                const Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Text(
                    'We\'ve sent you an email verification. please open it to verify your account.\n\n\n',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                const Text('Didn\'t recive an email? press the button below.'),

                ///Resend Code Button
                Container(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: 250,
                    height: 60,
                    child: TextButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0))),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.amber),
                      ),
                      onPressed: () async {
                        context.read<AuthBloc>().add(
                              const AuthEventSendEmailVerification(
                                  sendEmail: true),
                            );
                      },
                      child: const Text(
                        'Resend Code',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                ///Return to Login
                TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(const AuthEventLogOut());
                    },
                    child: const Text(
                      'Back to login page',
                      style: TextStyle(color: Colors.blue),
                    )),
              ],
            ),
          ),
        ),

        //     Column(
        //       children: [
        //         const Text(
        //             'We\'ve sent you an email verification. please open it to verify your account.\n\n\n'),
        //         const Text('Didn\'t recive an email? press the button below.'),
        //         TextButton(
        //           onPressed: () {
        //             context.read<AuthBloc>().add(
        //                   const AuthEventSendEmailVerification(sendEmail: true),
        //                 );
        //           },
        //           child: const Text('Send Verification Code'),
        //         ),
        //         TextButton(
        //             onPressed: () async {
        //               context.read<AuthBloc>().add(
        //                     const AuthEventLogOut(),
        //                   );
        //             },
        //             child: const Text('Not your email? Go back.'))
        //       ],
        //     ),
      ),
    );
  }
}
