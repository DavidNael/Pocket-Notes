import 'package:flutter/cupertino.dart';
import 'package:pocketnotes/utilities/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(
  BuildContext context,
) {
  return showGenericDialog<void>(
    context: context,
    title: 'Share Note',
    content: 'You Can\'t share empty note',
    optionsBuilder: () => {
      'Ok': Null,
    },
  );
}
