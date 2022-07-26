import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
                    final userInfo = await FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                            email: email, password: password);
                    print(userInfo);
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'invalid-email') {
                      print('Please Input Valid Email');
                    } else if (e.code == 'user-not-found') {
                      print('User Not Found');
                    } else if (e.code == 'wrong-password') {
                      print('Wrong Password');
                    } else
                      print(e.code);
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
                      .pushNamedAndRemoveUntil('/Register/', (route) => false);
                },
                child: const Text('Don\'t have an Account? Register'))
          ],
        ),
      ),
    );
  }
}
