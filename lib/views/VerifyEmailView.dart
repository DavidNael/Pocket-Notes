import 'package:flutter/material.dart';
import 'package:pocketnotes/Services/auth/auth-service.dart';
import 'package:pocketnotes/views/Constants/Routes.dart';
import '../firebase_options.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);
  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Column(
        children: [
          const Text(
              'We\'ve sent you an email verification. please open it to verify your account.\n\n\n'),
          const Text('Didn\'t recive an email? press the button below.'),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().sendEmailVerification();
            },
            child: const Text('Send Verification Code'),
          ),
          TextButton(
              onPressed: () async {
                await AuthService.firebase().logout();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(loginRoute, (route) => false);
              },
              child: const Text('Not your email? Go back.'))
        ],
      ),
    );
  }
}

Future<bool> emailConfirmation(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Email Verification'),
        content:
            const Text('An mail was sent to your Email to verify your account'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Ok')),
        ],
      );
    },
  ).then((value) => value ?? false);
}
