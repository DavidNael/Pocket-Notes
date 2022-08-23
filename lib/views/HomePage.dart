import 'package:flutter/material.dart';
import 'package:pocketnotes/Services/auth/auth-service.dart';
import 'package:pocketnotes/views/LoginView.dart';
import 'package:pocketnotes/views/Notes/notes_view.dart';
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
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isVerified) {
                return const NotesView();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }
          default:
            return const CircularProgressIndicator(
              value: 2,
            );
        }
      },
    );
  }
}
