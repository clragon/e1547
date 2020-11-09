import 'dart:async';

import 'package:e1547/login/components/progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginFields extends StatefulWidget {
  @override
  _LoginFieldsState createState() => _LoginFieldsState();
}

class _LoginFieldsState extends State<LoginFields> {
  final TextEditingController keyController = TextEditingController();

  bool didJustPaste = false;
  String previousPaste;

  bool authDidJustFail = false;

  Timer pasteUndoTimer;

  String username;
  String apiKey;

  @override
  void dispose() {
    super.dispose();
    pasteUndoTimer?.cancel();
  }

  Function() _saveAndTest(BuildContext context) {
    return () async {
      FormState form = Form.of(context)
        ..save(); // TODO: fix this so we don't need to save->validate->validate
      if (form.validate()) {
        showDialog(
          context: context,
          builder: (context) => LoginDialog(username, apiKey, (valid) {
            if (valid) {
              Navigator.of(context).pop();
            } else {
              authDidJustFail = true;
              form.validate();
              Scaffold.of(context).showSnackBar(SnackBar(
                  duration: Duration(seconds: 10),
                  content: Text('Failed to login. '
                      'Check your network connection and login details')));
            }
          }),
        );
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    Widget nameField() {
      return TextFormField(
        autocorrect: false,
        decoration: InputDecoration(
          labelText: 'Username',
        ),
        autofillHints: [AutofillHints.username],
        onSaved: (value) {
          authDidJustFail = false;
          username = value.trim();
        },
        validator: (value) {
          if (authDidJustFail) {
            return 'Failed to login. Please check username.';
          }
          if (username.trim().isEmpty) {
            return 'You must provide a username.';
          }
          return null;
        },
      );
    }

    Widget apiKeyWidget() {
      Widget keyField() {
        return TextFormField(
          autocorrect: false,
          controller: keyController,
          decoration: InputDecoration(
            labelText: 'API Key',
            helperText: 'e.g. 1ca1d165e973d7f8d35b7deb7a2ae54c',
          ),
          autofillHints: [AutofillHints.password],
          onSaved: (value) {
            authDidJustFail = false;
            apiKey = value.trim();
          },
          validator: (value) {
            if (authDidJustFail) {
              return 'Failed to login. Please check API key.\n'
                  'e.g. 1ca1d165e973d7f8d35b7deb7a2ae54c';
            }
            value = value.trim(); // ignore: parameter_assignments
            if (value.isEmpty) {
              return 'You must provide an API key.\n'
                  'e.g. 1ca1d165e973d7f8d35b7deb7a2ae54c';
            }
            if (!RegExp(r'^[A-z0-9]{24,32}$').hasMatch(value)) {
              return 'API key is a 24 or 32-character sequence of {A..z} and {0..9}\n'
                  'e.g. 1ca1d165e973d7f8d35b7deb7a2ae54c';
            }
            return null;
          },
        );
      }

      Widget pasteButton() {
        if (didJustPaste) {
          return IconButton(
            icon: Icon(Icons.undo),
            tooltip: 'Undo previous paste',
            onPressed: () {
              setState(() {
                didJustPaste = false;
                keyController.text = previousPaste;
              });
            },
          );
        } else {
          return IconButton(
            icon: Icon(Icons.content_paste),
            tooltip: 'Paste',
            onPressed: () async {
              var data = await Clipboard.getData('text/plain');
              if (data == null || data.text.trim().isEmpty) {
                Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text('Clipboard is empty')));
                return;
              }

              setState(() {
                didJustPaste = true;
                previousPaste = keyController.text;
                keyController.text = data.text;
              });

              pasteUndoTimer = Timer(Duration(seconds: 10), () {
                setState(() {
                  didJustPaste = false;
                });
              });
            },
          );
        }
      }

      return Row(children: [
        Expanded(child: keyField()),
        pasteButton(),
      ]);
    }

    Widget loginButton() {
      return Padding(
        padding: EdgeInsets.only(top: 26.0),
        child: RaisedButton(
          color: Theme.of(context).accentColor,
          child: Text(
            'LOGIN',
            style: Theme.of(context).accentTextTheme.button,
          ),
          onPressed: _saveAndTest(context),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          nameField(),
          apiKeyWidget(),
          loginButton(),
        ],
      ),
    );
  }
}
