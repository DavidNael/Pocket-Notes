import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pocketnotes/views/LoginView.dart';
import 'package:pocketnotes/views/VerifyEmailView.dart';
import '../firebase_options.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;
            print(user);
            user?.refreshToken;
            if (user != null) {
              if (user.emailVerified) {
                print('Email is Verified');
                return const Text('Done');
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }

            return const LoginView();
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
