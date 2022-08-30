import 'package:flutter/material.dart';

final loadingWidget = Scaffold(
    body: Center(
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: const [
      Text(
        'Loading...',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      CircularProgressIndicator(),
    ],
  ),
));
