import 'package:e1547/client/client.dart';
import 'package:flutter/material.dart';

Future<void> logout(BuildContext context) async {
  String? name = client.credentials?.username;
  await client.logout();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 1),
      content: Text('Forgot login details ${name != null ? ' for $name' : ''}'),
    ),
  );
}

Future<void> guardWithLogin({
  required BuildContext context,
  required VoidCallback callback,
  String? error,
}) async {
  if (client.hasLogin) {
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
