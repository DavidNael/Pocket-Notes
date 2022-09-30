import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../views/Constants/app_theme.dart';

typedef DialogOptionBuilder<T> = Map<String, T?> Function();
Future<T?> showGenericDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionBuilder optionsBuilder,
}) {
  bool isDarkMode = Provider.of<AppTheme>(context, listen: false).darkMode;

  final options = optionsBuilder();
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: isDarkMode ? darkBorderTheme : lightBorderTheme,
          title: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isDarkMode ? darkTextTheme : lightTextTheme,
              ),
            ),
          ),
          content: Text(
            content,
            style: TextStyle(
              color: isDarkMode ? darkTextTheme : lightTextTheme,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: options.keys.map((optionTitle) {
                final value = options[optionTitle];
                return TextButton(
                  onPressed: () {
                    if (value != null) {
                      Navigator.of(context).pop(value);
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(
                    optionTitle,
                    style: TextStyle(
                      color: isDarkMode ? darkTextTheme : lightTextTheme,
                    ),
                  ),
                );
              }).toList(),
            )
          ]);
    },
  );
}
