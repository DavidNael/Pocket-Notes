import 'package:flutter/material.dart';
import 'package:pocketnotes/Services/auth/Exceptions.dart';
import 'package:pocketnotes/Services/auth/auth-service.dart';
import 'package:pocketnotes/views/Constants/Routes.dart';

import '../utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textDecoration = InputDecoration(
      hintStyle: const TextStyle(fontWeight: FontWeight.bold),
      filled: true,
      fillColor: const Color.fromARGB(131, 158, 158, 158),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.all(30),
              padding: const EdgeInsets.all(1),
              width: 400,
              height: 60,
              child: TextField(
                  style: const TextStyle(color: Colors.black),
                  controller: _email,
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  decoration:
                      textDecoration.copyWith(hintText: 'Enter Your Email')),
            ),
            Container(
              margin: const EdgeInsets.all(30),
              padding: const EdgeInsets.all(1),
              width: 400,
              height: 60,
              child: TextField(
                  controller: _password,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  textAlign: TextAlign.center,
                  decoration:
                      textDecoration.copyWith(hintText: 'Enter Your Password')),
            ),
            Container(
              // padding: const EdgeInsets.all(21),
              margin: const EdgeInsets.all(31),
              width: 200,
              height: 60,
              decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                      side: BorderSide(color: Colors.black)),
                  color: const Color.fromRGBO(52, 229, 235, 100)),
              child: TextButton(
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;
                  try {
                    await AuthService.firebase().login(
                      email: email,
                      password: password,
                    );
                    final user = AuthService.firebase().currentUser;
                    if (user?.isVerified ?? false) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          notesRoute, (route) => false);
                    } else {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          verifyEmailRoute, (route) => false);
                    }
                  } on UserNotFoundAuthException {
                    await showErrorDialog(context, 'User Not Found');
                  } on WrongPasswordAuthException {
                    await showErrorDialog(context, 'Wrong Password');
                  } on EmptyEmailAuthException {
                    await showErrorDialog(context, 'Email can\'t be empty');
                  } on EmptyPasswordAuthException {
                    await showErrorDialog(context, 'Password can\'t be empty');
                  } on EmptyEmailPasswordAuthException {
                  } on InvalidEmailAuthException {
                    await showErrorDialog(context, 'Please enter Valid email');
                  } on UnknownAuthException {
                    await showErrorDialog(context,
                        'Unknown error, Make sure you are connected to the internet and try again.');
                  }
                },
                child: const Text('Login',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(registerRoute, (route) => false);
                },
                child: const Text('Don\'t have an Account? Register'))
          ],
        ),
      ),
    );
  }
}
