import 'dart:async' show Future, Timer;

import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard;
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Form(
              child: Column(children: [
            stepWidget(
                1,
                TextButton(
                  onPressed: () async {
                    launch('https://${await db.host.value}/session/new');
                  },
                  child: Text(
                    'Login via web browser',
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue[400]),
                  ),
                )),
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
            _LoginFormFields(),
          ]))),
    );
  }
}

class _LoginFormFields extends StatefulWidget {
  @override
  _LoginFormFieldsState createState() => _LoginFormFieldsState();
}

class _LoginFormFieldsState extends State<_LoginFormFields> {
  final TextEditingController _apiKeyFieldController = TextEditingController();

  bool _didJustPaste = false;
  String _beforePasteText;

  bool _authDidJustFail = false;

  Timer _pasteUndoTimer;

  String _username;
  String _apiKey;

  @override
  void dispose() {
    super.dispose();
    if (_pasteUndoTimer != null) {
      _pasteUndoTimer.cancel();
    }
  }

  void _saveUsername(String username) {
    _authDidJustFail = false;
    _username = username.trim();
  }

  void _saveApiKey(String apiKey) {
    _authDidJustFail = false;
    _apiKey = apiKey.trim();
  }

  String _validateUsername(String username) {
    if (_authDidJustFail) {
      return 'Failed to login. Please check username.';
    }

    if (username.trim().isEmpty) {
      return 'You must provide a username.';
    }

    return null;
  }

  String _validateApiKey(String apiKey) {
    if (_authDidJustFail) {
      return 'Failed to login. Please check API key.\n'
          'e.g. 1ca1d165e973d7f8d35b7deb7a2ae54c';
    }

    apiKey = apiKey.trim();
    if (apiKey.isEmpty) {
      return 'You must provide an API key.\n'
          'e.g. 1ca1d165e973d7f8d35b7deb7a2ae54c';
    }

    if (!RegExp(r'^[A-z0-9]{24,32}$').hasMatch(apiKey)) {
      return 'API key is a 24 or 32-character sequence of {A..z} and {0..9}\n'
          'e.g. 1ca1d165e973d7f8d35b7deb7a2ae54c';
    }

    return null;
  }

  Function() _saveAndTest(BuildContext context) {
    return () async {
      FormState form = Form.of(context)..save();
      if (form.validate()) {
        bool ok = await showDialog(
          context: context,
          builder: (context) => _LoginProgressDialog(_username, _apiKey),
        );

        if (ok) {
          Navigator.of(context).pop();
        } else {
          _authDidJustFail = true;
          form.validate();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: Duration(seconds: 10),
              content: Text('Failed to login. '
                  'Check your network connection and login details')));
        }
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    Widget usernameWidget() {
      return TextFormField(
        autocorrect: false,
        decoration: InputDecoration(
          labelText: 'Username',
        ),
        autofillHints: [AutofillHints.username],
        onSaved: _saveUsername,
        validator: _validateUsername,
      );
    }

    Widget apiKeyWidget() {
      Widget textEntryWidget() {
        return TextFormField(
          autocorrect: false,
          controller: _apiKeyFieldController,
          decoration: InputDecoration(
            labelText: 'API Key',
            helperText: 'e.g. 1ca1d165e973d7f8d35b7deb7a2ae54c',
          ),
          autofillHints: [AutofillHints.password],
          onSaved: _saveApiKey,
          validator: _validateApiKey,
        );
      }

      Widget specialActionWidget() {
        if (_didJustPaste) {
          return IconButton(
            icon: Icon(Icons.undo),
            tooltip: 'Undo previous paste',
            onPressed: () {
              setState(() {
                _didJustPaste = false;
                _apiKeyFieldController.text = _beforePasteText;
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
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Clipboard is empty')));
                return;
              }

              setState(() {
                _didJustPaste = true;
                _beforePasteText = _apiKeyFieldController.text;
                _apiKeyFieldController.text = data.text;
              });

              _pasteUndoTimer = Timer(Duration(seconds: 10), () {
                setState(() {
                  _didJustPaste = false;
                });
              });
            },
          );
        }
      }

      return Row(children: [
        Expanded(child: textEntryWidget()),
        specialActionWidget(),
      ]);
    }

    Widget saveAndTestWidget() {
      return Padding(
        padding: EdgeInsets.only(top: 26.0),
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
              Theme.of(context).accentColor,
            ),
          ),
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
          usernameWidget(),
          apiKeyWidget(),
          saveAndTestWidget(),
        ],
      ),
    );
  }
}

class _LoginProgressDialog extends StatefulWidget {
  final String username;
  final String apiKey;

  _LoginProgressDialog(this.username, this.apiKey);

  @override
  _LoginProgressDialogState createState() => _LoginProgressDialogState();
}

class _LoginProgressDialogState extends State<_LoginProgressDialog> {
  Future<bool> _isLoginOk;

  @override
  void initState() {
    super.initState();
    _isLoginOk = client.saveLogin(
      widget.username,
      widget.apiKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    _isLoginOk.then((ok) {
      Navigator.of(context).pop(ok);
    });

    return Dialog(
        child: Container(
      padding: EdgeInsets.all(20.0),
      child: Row(children: [
        SizedCircularProgressIndicator(size: 28),
        Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text('Logging in as ${widget.username}'),
        )
      ]),
    ));
  }
}
