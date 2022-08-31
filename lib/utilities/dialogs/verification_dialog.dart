import 'package:flutter/cupertino.dart';
import 'package:pocketnotes/utilities/dialogs/generic_dialog.dart';

Future<bool> showVerificationDialog(
  BuildContext context,
) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Verify Email',
    content:
        'We\'ve sent you an email verification. please open it to verify your account.',
    optionsBuilder: () => {
      'Ok': true,
    },
  ).then((value) => value ?? true);
}
