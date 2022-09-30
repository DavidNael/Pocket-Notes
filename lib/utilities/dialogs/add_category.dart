import 'package:flutter/material.dart';
import 'package:pocketnotes/Services/cloud/cloud_note.dart';
import 'package:pocketnotes/Services/cloud/cloud_user.dart';
import 'package:pocketnotes/Services/cloud/firebase_cloud_storage.dart';

import '../../views/Constants/app_theme.dart';

Future<void> addCategory(
  BuildContext context, {
  required String title,
  required FirebaseCloudStorage notesService,
  required CloudUser user,
  required bool isDarkMode,
  required Color themeColor,
}) {
  final addCategory = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  return showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setstate) {
        return AlertDialog(
          scrollable: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: isDarkMode ? darkBorderTheme : lightBorderTheme,
          title: Text(
            title,
            style: TextStyle(
              color: isDarkMode ? darkTextTheme : lightTextTheme,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Form(
                key: addCategory,
                child: TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Can\'t save empty category.';
                    } else if (user.userCategories.contains(value)) {
                      return '$value category already exists.';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    color: isDarkMode ? darkTextTheme : lightTextTheme,
                  ),
                  controller: name,
                  enableSuggestions: false,
                  autocorrect: false,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 5,
                    ),
                    labelText: 'Name:',
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? darkTextTheme : lightTextTheme,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: isDarkMode ? darkTextTheme : lightTextTheme,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: themeColor,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //!Cancel Button
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: isDarkMode ? darkTextTheme : lightTextTheme,
                      ),
                    ),
                  ),
                  //!Add Button
                  TextButton(
                    onPressed: () async {
                      if (addCategory.currentState!.validate()) {
                        List<dynamic> newList = user.userCategories;
                        newList.add(name.text);
                        await notesService.updateUser(
                          documentId: user.documentId,
                          userName: user.userName,
                          userImage: user.userImage,
                          userPhone: user.userPhone,
                          userCategories: newList,
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      'Add',
                      style: TextStyle(
                        color: isDarkMode ? darkTextTheme : lightTextTheme,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      });
    },
  );
}
