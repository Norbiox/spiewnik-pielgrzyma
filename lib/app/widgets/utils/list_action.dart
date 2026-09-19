import 'package:flutter/material.dart';

/// Runs a list mutation and reports failure to the user.
///
/// The mutation has already been applied locally by the time this returns, so
/// the UI is responsive; a throw means the change was rolled back and the user
/// needs to know.
Future<void> runListAction(
    BuildContext context, Future<void> Function() action) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await action();
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Nie udało się zapisać zmiany. Sprawdź połączenie.'),
      ),
    );
  }
}
