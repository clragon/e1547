// e1547: A mobile app for browsing e926.net and friends.
// Copyright (C) 2017 perlatus <perlatus@e1547.email.vczf.io>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

import 'dart:async' show Future, Timer;
import 'dart:ui' show VoidCallback;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show TextInputFormatter, Clipboard;

import 'package:logging/logging.dart' show Logger;
import 'package:url_launcher/url_launcher.dart' as url;

import 'client.dart' show client;
import 'persistence.dart' as persistence;

class LoginPage extends StatelessWidget {
  final Future<String> _host = persistence.getHost();

  @override
  Widget build(BuildContext ctx) {
    List<Widget> columnChildren = [
      new _InstructionStep(
          1, _buttonLink('Login via web browser', '/user/login')),
      new _InstructionStep(
          2, _buttonLink('Enable API Access', '/user/api_key')),
      new _InstructionStep(3, new Text('Copy and paste your API key')),
    ];

    columnChildren.add(new _LoginFormFields());

    return new Scaffold(
      appBar: new AppBar(title: new Text('Login')),
      body: new SingleChildScrollView(
          padding: new EdgeInsets.all(10.0),
          child: new Form(child: new Column(children: columnChildren))),
    );
  }

  Function _launch(String path) {
    return () {
      _host.then((h) {
        url.launch('https://$h$path');
      });
    };
  }

  FlatButton _buttonLink(String text, String path) {
    return new FlatButton(
      onPressed: _launch(path),
      child: new Text(
        text,
        style: new TextStyle(decoration: TextDecoration.underline),
      ),
    );
  }
}

class _LoginFormFields extends StatefulWidget {
  @override
  _LoginFormFieldsState createState() => new _LoginFormFieldsState();
}

class _LoginFormFieldsState extends State<_LoginFormFields> {
  static final Logger _log = new Logger('LoginFormFields');

  TextEditingController _apiKeyFieldController = new TextEditingController();

  bool _didJustPaste = false;
  String _beforePasteText;

  bool _authDidJustFail = false;

  Timer _pasteUndoTimer;

  String _username;
  String _apiKey;

  @override
  Widget build(BuildContext ctx) {
    List<Widget> columnChildren = [];

    columnChildren.add(new TextFormField(
      autocorrect: false,
      decoration: const InputDecoration(
        labelText: 'Username',
      ),
      onSaved: (u) {
        _authDidJustFail = false;
        _username = u;
      },
      validator: (u) {
        if (_authDidJustFail) {
          return 'Failed to login. Please check username.';
        }

        u = u.trim();
        if (u.isEmpty) {
          return 'You must provide a username.';
        }
      },
    ));

    columnChildren.add(new Row(children: [
      new Expanded(
        child: new TextFormField(
          autocorrect: false,
          controller: _apiKeyFieldController,
          decoration: const InputDecoration(
            labelText: 'API Key',
            helperText: 'e.g. 1ca1d165e973d7f8d35b7deb7a2ae54c',
          ),
          inputFormatters: [new _LowercaseTextInputFormatter()],
          onSaved: (a) {
            _authDidJustFail = false;
            _apiKey = a;
          },
          validator: (apiKey) {
            if (_authDidJustFail) {
              return 'Failed to login. Please check API key.\n'
                  'e.g. 1ca1d165e973d7f8d35b7deb7a2ae54c';
            }

            apiKey = apiKey.trim();
            if (apiKey.isEmpty) {
              return 'You must provide an API key.\n'
                  'e.g. 1ca1d165e973d7f8d35b7deb7a2ae54c';
            }

            if (!new RegExp(r"^[a-f0-9]{32}$").hasMatch(apiKey)) {
              return 'API key is a 32-character sequence of {a..f} and {0..9}\n'
                  'e.g. 1ca1d165e973d7f8d35b7deb7a2ae54c';
            }

            return null;
          },
        ),
      ),
      _didJustPaste
          ? new IconButton(
              icon: new Icon(Icons.undo),
              tooltip: 'Undo previous paste',
              onPressed: () {
                setState(() {
                  _didJustPaste = false;
                  _apiKeyFieldController.text = _beforePasteText;
                });
              },
            )
          : new IconButton(
              icon: new Icon(Icons.content_paste),
              tooltip: 'Paste',
              onPressed: () async {
                var data = await Clipboard.getData('text/plain');
                if (data == null || data.text.trim().isEmpty) {
                  Scaffold.of(ctx).showSnackBar(
                      new SnackBar(content: new Text('Clipboard is empty')));
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
              }),
    ]));

    columnChildren.add(new Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: new RaisedButton(
        child: new Text('SAVE & TEST'),
        onPressed: _saveAndTest(ctx),
      ),
    ));

    return new Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: columnChildren,
    );
  }

  VoidCallback _saveAndTest(ctx) => () async {
        _log.fine('Pressed SAVE & TEST');
        FormState form = Form.of(ctx);
        form.save(); // TODO: fix this so we don't need to save->validate->validate
        if (form.validate()) {
          _log.fine('username: $_username ; apikey: $_apiKey');
          bool ok = await showDialog(
            context: ctx,
            child: new _LoginProgressDialog(_username, _apiKey),
          );

          if (ok) {
            persistence.setUsername(_username);
            persistence.setApiKey(_apiKey);

            Navigator.of(ctx).pop();
          } else {
            _authDidJustFail = true;
            form.validate();
            Scaffold.of(ctx).showSnackBar(new SnackBar(
                duration: const Duration(seconds: 10),
                content: new Text('Failed to login. '
                    'Check your network connection and login details')));
          }
        }
      };

  @override
  void dispose() {
    super.dispose();
    if (_pasteUndoTimer != null) {
      _pasteUndoTimer.cancel();
    }
  }
}

class _LoginProgressDialog extends StatefulWidget {
  final String username;
  final String apiKey;
  _LoginProgressDialog(this.username, this.apiKey, {Key key}) : super(key: key);

  @override
  _LoginProgressDialogState createState() => new _LoginProgressDialogState();
}

class _LoginProgressDialogState extends State<_LoginProgressDialog> {
  static final Logger _log = new Logger('LoginProgressDialog');

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
  final int _stepNumber;
  final Widget _content;

  _InstructionStep(this._stepNumber, this._content, {Key key})
      : super(key: key);
  @override
  Widget build(BuildContext ctx) {
    Widget leadingCircle = new Container(
      decoration: new ShapeDecoration(
        color: Colors.white,
        shape: new CircleBorder(),
      ),
      width: 64.0,
      height: 64.0,
      alignment: Alignment.center,
      child: new Text(
        _stepNumber.toString(),
        textAlign: TextAlign.center,
        style: new TextStyle(color: Colors.black, fontSize: 48.0),
      ),
    );

    return new Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            leadingCircle,
            new Expanded(child: new Container()),
            _content,
            new Expanded(child: new Container()),
          ]),
    );
  }
}

class _LowercaseTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(prev, current) {
    return current.copyWith(text: current.text.toLowerCase());
  }
}
