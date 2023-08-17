import 'dart:async';

import 'package:flutter/material.dart';

typedef StartupCallback = FutureOr<void> Function(BuildContext context);

class StartupActions extends StatefulWidget {
  const StartupActions({
    required this.child,
    required this.actions,
    this.onError,
  });

  /// List of all actions to execute when this widget is instantiated
  final List<StartupCallback> actions;

  /// The error handler for any action that fails. If this is is null, the errors are thrown like normal.
  final void Function(Object error)? onError;

  /// The child widget.
  final Widget child;

  @override
  State<StartupActions> createState() => _StartupActionsState();
}

class _StartupActionsState extends State<StartupActions> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final element in widget.actions) {
        Future<void>(() async {
          try {
            await element(context);
          } on Exception catch (e) {
            if (widget.onError != null) {
              widget.onError!(e);
            } else {
              rethrow;
            }
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
