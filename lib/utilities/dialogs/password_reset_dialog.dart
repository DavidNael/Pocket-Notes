import 'package:flutter/cupertino.dart';
import 'package:pocketnotes/utilities/dialogs/generic_dialog.dart';

Future<bool> showPasswordResetDialog(
  BuildContext context,
) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Password Reset',
    content:
        'We\'ve sent you a password reset link. please check your email to reset your password.',
    optionsBuilder: () => {
      'Ok': true,
    },
  ).then((value) => value ?? true);
}
