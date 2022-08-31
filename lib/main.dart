import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketnotes/Services/auth/bloc/auth_bloc.dart';
import 'package:pocketnotes/Services/auth/firebase-provider.dart';
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
        primarySwatch: Colors.amber,
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FireBaseProvider()),
        child: const HomePage(),
      ),
      routes: {
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}
