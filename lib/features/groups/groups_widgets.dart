import 'package:flutter/material.dart';

import 'groups_models.dart';

export '../../core/widgets/dialogs.dart';

void showGroupsError(BuildContext context, Object error) {
  final text = error is GroupsException
      ? error.message
      : 'Could not reach the server. Try again.';
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(text)));
}

void showGroupsMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(message)));
}
