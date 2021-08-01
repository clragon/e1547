import 'dart:async' show Future, Timer;

import 'package:e1547/client.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard;
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatelessWidget {
  Widget stepWidget(int stepNumber, Widget content) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(children: [
        Container(
          width: 36.0,
          height: 36.0,
          alignment: Alignment.center,
          child: Text(
            stepNumber.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26.0),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 16),
          child: content,
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: [
              stepWidget(
                1,
                TextButton(
                  onPressed: () async {
                    launch('https://${await settings.host.value}/session/new');
                  },
                  child: Text(
                    'Login via web browser',
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue[400]),
                  ),
                ),
              ),
              stepWidget(
                  2,
                  Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Enable API Access'))),
              stepWidget(
                  3,
                  Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Copy and paste your API key'))),
              LoginFormFields(),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginFormFields extends StatefulWidget {
  @override
  _LoginFormFieldsState createState() => _LoginFormFieldsState();
}

class _LoginFormFieldsState extends State<LoginFormFields> {
  final TextEditingController apiKeyFieldController = TextEditingController();

  String? username;
  String? apiKey;

  bool authFailed = false;

  bool justPasted = false;
  String? previousPaste;
  Timer? pasteUndoTimer;

  @override
  void dispose() {
    super.dispose();
    pasteUndoTimer?.cancel();
  }

  Future<void> saveAndTest() async {
    FormState form = Form.of(context)!..save();
    if (form.validate()) {
      showDialog(
        context: context,
        builder: (context) => LoginProgressDialog(
          username: username,
          apiKey: apiKey,
          onResult: (value) {
            if (value) {
              Navigator.of(context).maybePop();
            } else {
              authFailed = true;
              form.validate();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: Duration(seconds: 10),
                  content: Text('Failed to login. '
                      'Check your network connection and login details')));
            }
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget usernameField() {
      return TextFormField(
        autocorrect: false,
        decoration: InputDecoration(
          labelText: 'Username',
        ),
        autofillHints: [AutofillHints.username],
        onSaved: (value) {
          authFailed = false;
          username = value!.trim();
        },
        validator: (value) {
          if (authFailed) {
            return 'Failed to login. Please check username.';
          }

          if (username!.trim().isEmpty) {
            return 'You must provide a username.';
          }

          return null;
        },
      );
    }

    Widget apiKeyField() {
      String apiKeyExample = '1ca1d165e973d7f8d35b7deb7a2ae54c';

      Widget inputField() {
        return TextFormField(
          autocorrect: false,
          controller: apiKeyFieldController,
          decoration: InputDecoration(
            labelText: 'API Key',
            helperText: 'e.g. $apiKeyExample',
          ),
          autofillHints: [AutofillHints.password],
          onSaved: (value) {
            authFailed = false;
            apiKey = value!.trim();
          },
          validator: (value) {
            if (authFailed) {
              return 'Failed to login. Please check API key.\n'
                  'e.g. $apiKeyExample';
            }

            apiKey = value!.trim();
            if (apiKey!.isEmpty) {
              return 'You must provide an API key.\n'
                  'e.g. $apiKeyExample';
            }

            if (!RegExp(r'^[A-z0-9]{24,32}$').hasMatch(apiKey!)) {
              return 'API key is a 24 or 32-character sequence of {A..z} and {0..9}\n'
                  'e.g. $apiKeyExample';
            }

            return null;
          },
        );
      }

      Widget pasteButton() {
        if (justPasted) {
          return IconButton(
            icon: Icon(Icons.undo),
            tooltip: 'Undo previous paste',
            onPressed: () {
              setState(() {
                justPasted = false;
                apiKeyFieldController.text = previousPaste!;
              });
            },
          );
        } else {
          return IconButton(
            icon: Icon(Icons.content_paste),
            tooltip: 'Paste',
            onPressed: () async {
              var data = await Clipboard.getData('text/plain');
              if (data == null || data.text!.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Clipboard is empty')));
                return;
              }

              setState(() {
                justPasted = true;
                previousPaste = apiKeyFieldController.text;
                apiKeyFieldController.text = data.text!;
              });

              pasteUndoTimer = Timer(Duration(seconds: 10), () {
                setState(() {
                  justPasted = false;
                });
              });
            },
          );
        }
      }

      return Row(children: [
        Expanded(child: inputField()),
        pasteButton(),
      ]);
    }

    Widget loginButton() {
      return Padding(
        padding: EdgeInsets.only(top: 26.0),
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              if (!states.contains(MaterialState.disabled)) {
                return Theme.of(context).accentColor;
              }
              return null;
            }),
          ),
          child: Text(
            'LOGIN',
            style: Theme.of(context).accentTextTheme.button,
          ),
          onPressed: saveAndTest,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          usernameField(),
          apiKeyField(),
          loginButton(),
        ],
      ),
    );
  }
}

class LoginProgressDialog extends StatefulWidget {
  final String? username;
  final String? apiKey;
  final Function(bool value) onResult;

  LoginProgressDialog({
    required this.username,
    required this.apiKey,
    required this.onResult,
  });

  @override
  _LoginProgressDialogState createState() => _LoginProgressDialogState();
}

class _LoginProgressDialogState extends State<LoginProgressDialog> {
  @override
  void initState() {
    super.initState();
    client.saveLogin(widget.username!, widget.apiKey!).then((value) async {
      await Navigator.of(context).maybePop();
      widget.onResult(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(20.0),
        child: Row(children: [
          Padding(
            padding: EdgeInsets.all(4),
            child: Container(
              height: 28,
              width: 28,
              child: CircularProgressIndicator(),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 16),
            child: Text('Logging in as ${widget.username}'),
          )
        ]),
      ),
    );
  }
}
