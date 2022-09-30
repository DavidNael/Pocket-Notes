import 'package:flutter/material.dart';
import 'package:pocketnotes/views/Constants/app_theme.dart';
import 'package:provider/provider.dart';

typedef CloseDialog = void Function();

CloseDialog showLoadingDialog({
  required BuildContext context,
  required String text,
}) {
  bool isDarkMode = Provider.of<AppTheme>(context, listen: false).darkMode;

  final dialog = AlertDialog(
    backgroundColor: isDarkMode ? darkBorderTheme : lightBorderTheme,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: TextStyle(
            color: isDarkMode ? darkTextTheme : lightTextTheme,
          ),
        ),
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
