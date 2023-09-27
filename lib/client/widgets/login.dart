import 'dart:async';

import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

Future<void> guardWithLogin({
  required BuildContext context,
  required VoidCallback callback,
  String? error,
}) async {
  if (context.read<Client>().hasLogin) {
    callback();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1),
        content: Text(error ?? 'You must be logged in to do that!'),
      ),
    );
    Navigator.of(context).pushNamed('/login');
  }
}
