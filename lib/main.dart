import 'package:flutter/material.dart';
import 'package:pocketnotes/views/HomePage.dart';
import 'package:pocketnotes/views/LoginView.dart';
import 'package:pocketnotes/views/RegisterView.dart';

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
        '/Login/':(context) => const LoginView(),
        '/Register/':(context) => const RegisterView(),
        
      },
    ),
  );
}
