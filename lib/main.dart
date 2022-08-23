import 'package:flutter/material.dart';
import 'package:pocketnotes/views/Constants/Routes.dart';
import 'package:pocketnotes/views/HomePage.dart';
import 'package:pocketnotes/views/LoginView.dart';
import 'package:pocketnotes/views/Notes/notes_view.dart';
import 'package:pocketnotes/views/RegisterView.dart';
import 'package:pocketnotes/views/VerifyEmailView.dart';
import 'package:pocketnotes/views/Notes/create_update_note_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized;
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        notesRoute: (context) => const NotesView(),
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}
