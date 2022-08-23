import 'package:flutter/material.dart';
import 'package:pocketnotes/Services/auth/Exceptions.dart';
import 'package:pocketnotes/Services/auth/auth-service.dart';
import 'package:pocketnotes/views/Constants/Routes.dart';

import '../Container Blocks/Form.dart';
import '../utilities/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
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
                      side: const BorderSide(color: Colors.black)),
                  color: const Color.fromRGBO(52, 229, 235, 100)),
              child: TextButton(
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;
                  try {
                    await AuthService.firebase()
                        .createUser(email: email, password: password);
                    AuthService.firebase().sendEmailVerification();
                    Navigator.of(context).pushNamed(verifyEmailRoute);
                  } on WeakPasswordAuthException {
                    await showErrorDialog(context,
                        'Weak password, make sure to use at least 8 characters.');
                  } on EmailExistsAuthException {
                    await showErrorDialog(context, 'Email already exists');
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
                child: const Text('Register',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(loginRoute, (route) => false);
                },
                child: const Text('Already have an Account? Login'))
          ],
        ),
      ),
    );
  }
}
