import 'package:flutter/material.dart';
import 'package:pocketnotes/Services/cloud/cloud_note.dart';
import 'package:pocketnotes/Services/cloud/cloud_user.dart';
import 'package:pocketnotes/Services/cloud/firebase_cloud_storage.dart';

import '../../views/Constants/app_theme.dart';

Future<void> selectCategory(
  BuildContext context, {
  required String title,
  required FirebaseCloudStorage notesService,
  required CloudUser user,
  required CloudNote note,
  required bool isDarkMode,
}) {
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
            children:
                List<Widget>.generate(user.userCategories.length, (index) {
              return TextButton(
                onPressed: () {
                  List<dynamic> newList = note.noteCategories;
                  if (note.noteCategories
                      .contains(user.userCategories[index])) {
                    newList.remove(user.userCategories[index]);
                    notesService.updateNotes(
                      documentId: note.documentId,
                      title: note.title,
                      titleJson: note.titleJson,
                      note: note.note,
                      noteJson: note.noteJson,
                      dateModified: note.dateModified,
                      isPinned: note.isPinned,
                      isArchived: note.isArchived,
                      isTrashed: note.isTrashed,
                      categories: newList,
                    );
                    setstate(() {});
                  } else {
                    newList.add(user.userCategories[index]);
                    notesService.updateNotes(
                      documentId: note.documentId,
                      title: note.title,
                      titleJson: note.titleJson,
                      note: note.note,
                      noteJson: note.noteJson,
                      dateModified: note.dateModified,
                      isPinned: note.isPinned,
                      isArchived: note.isArchived,
                      isTrashed: note.isTrashed,
                      categories: newList,
                    );
                    setstate(() {});
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      user.userCategories[index] + ' :',
                      style: TextStyle(
                        color: isDarkMode ? darkTextTheme : lightTextTheme,
                      ),
                    ),
                    Icon(
                      note.noteCategories.contains(user.userCategories[index])
                          ? Icons.check
                          : null,
                    ),
                  ],
                ),
              );
            }),
          ),
        );
      });
    },
  );
}
