import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketnotes/Services/auth/bloc/auth_bloc.dart';
import 'package:pocketnotes/Services/auth/firebase_provider.dart';
import 'package:pocketnotes/views/Constants/routes.dart';
import 'package:pocketnotes/views/Notes/test.dart';
import 'package:pocketnotes/views/controller_view.dart';
import 'package:pocketnotes/views/forgot_password.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized;
  runApp(
    MaterialApp(
      title: 'Pocket Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FireBaseProvider()),
        child: const ControllerView(),
      ),
      routes: {
        createOrUpdateNoteRoute: (context) => const TestNote(),
        forgotPasswordRoute: (context) => const ForgotPasswordView(),
      },
    ),
  );
}
