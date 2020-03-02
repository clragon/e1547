// TODO: rework spacing.

import 'dart:async' show Future, Timer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard;

import 'package:url_launcher/url_launcher.dart' as url;

import 'client.dart' show client;
import 'input.dart' show LowercaseTextInputFormatter;
import 'persistence.dart' show db;

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    List<Widget> columnChildren = [
      new _InstructionStep(
          1, _buttonLink('Login via web browser', '/user/login')),
      new _InstructionStep(
          2, _buttonLink('Enable API Access', '/user/api_key')),
      const _InstructionStep(3, const Text('Copy and paste your API key')),
      new _LoginFormFields(),
    ];

    return new Scaffold(
      appBar: new AppBar(title: const Text('Login')),
      body: new SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: new Form(child: new Column(children: columnChildren))),
    );
  }

  Function() _launch(String path) {
    return () {
      db.host.value.then((h) {
        url.launch('https://$h$path');
      });
    };
  }

  FlatButton _buttonLink(String text, String path) {
    return new FlatButton(
      onPressed: _launch(path),
      child: new Text(
        text,
        style: const TextStyle(decoration: TextDecoration.underline),
      ),
    );
  }
}

class _LoginFormFields extends StatefulWidget {
  @override
  _LoginFormFieldsState createState() => new _LoginFormFieldsState();
}

class _LoginFormFieldsState extends State<_LoginFormFields> {

  final TextEditingController _apiKeyFieldController =
      new TextEditingController();

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

    apiKey = apiKey.trim(); // ignore: parameter_assignments
    if (apiKey.isEmpty) {
      return 'You must provide an API key.\n'
          'e.g. 1ca1d165e973d7f8d35b7deb7a2ae54c';
    }

    if (!new RegExp(r'^[a-f0-9]{32}$').hasMatch(apiKey)) {
      return 'API key is a 32-character sequence of {a..f} and {0..9}\n'
          'e.g. 1ca1d165e973d7f8d35b7deb7a2ae54c';
    }

    return null;
  }

  Function() _saveAndTest(BuildContext ctx) {
    return () async {
      FormState form = Form.of(ctx)
        ..save(); // TODO: fix this so we don't need to save->validate->validate
      if (form.validate()) {
        bool ok = await showDialog(
          context: ctx,
          builder: (ctx) => new _LoginProgressDialog(_username, _apiKey),
        );

        if (ok) {

          db.username.value = new Future.value(_username);
          db.apiKey.value = new Future.value(_apiKey);

          Navigator.of(ctx).pop();
        } else {

          _authDidJustFail = true;
          form.validate();
          Scaffold.of(ctx).showSnackBar(const SnackBar(
              duration: const Duration(seconds: 10),
              content: const Text('Failed to login. '
                  'Check your network connection and login details')));
        }
      }
    };
  }

  @override
  Widget build(BuildContext ctx) {
    Widget usernameWidget() {
      return new TextFormField(
        autocorrect: false,
        decoration: const InputDecoration(
          labelText: 'Username',
        ),
        onSaved: _saveUsername,
        validator: _validateUsername,
      );
    }

    Widget apiKeyWidget() {
      Widget textEntryWidget() {
        return new TextFormField(
          autocorrect: false,
          controller: _apiKeyFieldController,
          decoration: const InputDecoration(
            labelText: 'API Key',
            helperText: 'e.g. 1ca1d165e973d7f8d35b7deb7a2ae54c',
          ),
          inputFormatters: [new LowercaseTextInputFormatter()],
          onSaved: _saveApiKey,
          validator: _validateApiKey,
        );
      }

      Widget specialActionWidget() {
        if (_didJustPaste) {
          return new IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Undo previous paste',
            onPressed: () {
              setState(() {
                _didJustPaste = false;
                _apiKeyFieldController.text = _beforePasteText;
              });
            },
          );
        } else {
          return new IconButton(
            icon: const Icon(Icons.content_paste),
            tooltip: 'Paste',
            onPressed: () async {
              var data = await Clipboard.getData('text/plain');
              if (data == null || data.text.trim().isEmpty) {
                Scaffold.of(ctx).showSnackBar(
                    const SnackBar(content: const Text('Clipboard is empty')));
                return;
              }

              setState(() {
                _didJustPaste = true;
                _beforePasteText = _apiKeyFieldController.text;
                _apiKeyFieldController.text = data.text;
              });

              _pasteUndoTimer = new Timer(const Duration(seconds: 10), () {
                setState(() {
                  _didJustPaste = false;
                });
              });
            },
          );
        }
      }

      return new Row(children: [
        new Expanded(child: textEntryWidget()),
        specialActionWidget(),
      ]);
    }

    Widget saveAndTestWidget() {
      return new Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: new RaisedButton(
          child: const Text('SAVE & TEST'),
          onPressed: _saveAndTest(ctx),
        ),
      );
    }

    return new Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        usernameWidget(),
        apiKeyWidget(),
        saveAndTestWidget(),
      ],
    );
  }
}

class _LoginProgressDialog extends StatefulWidget {
  const _LoginProgressDialog(this.username, this.apiKey, {Key key})
      : super(key: key);

  final String username;
  final String apiKey;

  @override
  _LoginProgressDialogState createState() => new _LoginProgressDialogState();
}

class _LoginProgressDialogState extends State<_LoginProgressDialog> {
  Future<bool> _isLoginOk;

  @override
  void initState() {
    super.initState();
    _isLoginOk = client.isValidAuthPair(
      widget.username,
      widget.apiKey,
    );
  }

  @override
  Widget build(BuildContext ctx) {
    _isLoginOk.then((ok) {
      Navigator.of(ctx).pop(ok);
    });

    return new Dialog(
        child: new Container(
      padding: const EdgeInsets.all(20.0),
      child:
          new Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const CircularProgressIndicator(),
        new Text('Logging in as ${widget.username}'),
      ]),
    ));
  }
}

class _InstructionStep extends StatelessWidget {
  const _InstructionStep(this._stepNumber, this._content, {Key key})
      : super(key: key);

  final int _stepNumber;
  final Widget _content;

  @override
  Widget build(BuildContext ctx) {
    Widget leadingCircleWidget() {
      return new Container(
        decoration: const ShapeDecoration(
          color: Colors.white,
          shape: const CircleBorder(),
        ),
        width: 64.0,
        height: 64.0,
        alignment: Alignment.center,
        child: new Text(
          _stepNumber.toString(),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black, fontSize: 48.0),
        ),
      );
    }

    return new Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child:
          new Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        leadingCircleWidget(),
        new Expanded(child: new Container()),
        _content,
        new Expanded(child: new Container()),
      ]),
    );
  }
}
