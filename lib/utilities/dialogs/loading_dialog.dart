import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef CloseDialog = void Function();

CloseDialog ShowLoadingDialog({
  required BuildContext context,
  required String text,
}) {
  final dialog = AlertDialog(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text),
        const SizedBox(height: 10.0),
        const CircularProgressIndicator(),
      ],
    ),
  );
  showDialog(
    context: context,
    builder: (context) => dialog,
    barrierDismissible: false,
  );
  return () => Navigator.of(context).pop();
}
