import 'package:flutter/cupertino.dart';
import 'package:pocketnotes/utilities/dialogs/generic_dialog.dart';

Future<void> showInfoDialog(BuildContext context,
    {required String title, required String content}) {
  return showGenericDialog<void>(
    context: context,
    title: title,
    content: content,
    optionsBuilder: () => {
      'Ok': Null,
    },
  );
}
