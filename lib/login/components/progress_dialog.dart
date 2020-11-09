import 'package:e1547/services/client.dart';
import 'package:flutter/material.dart';

class LoginDialog extends StatefulWidget {
  final String username;
  final String apiKey;
  final void Function(bool) onLogin;

  LoginDialog(this.username, this.apiKey, this.onLogin);

  @override
  _LoginDialogState createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  Future<bool> valid;

  @override
  void initState() {
    super.initState();
    valid = client.saveLogin(
      widget.username,
      widget.apiKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    valid.then((ok) {
      widget.onLogin(ok);
      Navigator.of(context).pop();
    });

    return Dialog(
        child: Container(
      padding: EdgeInsets.all(20.0),
      child: Row(children: [
        Container(
          height: 28,
          width: 28,
          child: CircularProgressIndicator(),
        ),
        Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text('Logging in as ${widget.username}'),
        )
      ]),
    ));
  }
}
