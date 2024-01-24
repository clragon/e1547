import 'dart:async';

import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
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
        content:
            Text(error ?? 'This action is not available to anonymous users'),
        action: SnackBarAction(
          label: 'Switch identity',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const IdentitiesPage(),
            ),
          ),
        ),
      ),
    );
  }
}
