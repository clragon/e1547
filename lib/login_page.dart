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

import 'dart:async' show Future;

import 'package:flutter/material.dart';

import 'package:logging/logging.dart' show Logger;
import 'package:url_launcher/url_launcher.dart' as url;

import 'persistence.dart' as persistence;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static final Logger _log = new Logger('LoginPage');
  Future<String> _host = persistence.getHost();

  @override
  Widget build(BuildContext ctx) {
    List<Widget> columnChildren = [];

    columnChildren.add(new _InstructionStep(
      1,
      new FlatButton(
        onPressed: () => _host.then((h) {
              url.launch('https://$h/user/login');
            }),
        child: new Text(
          'Login via web browser',
          style: new TextStyle(decoration: TextDecoration.underline),
        ),
      ),
    ));

    columnChildren.add(new _InstructionStep(
      2,
      new FlatButton(
        onPressed: () => _host.then((h) {
              url.launch('https://$h/user/api_key');
            }),
        child: new Text(
          'Enable API Access',
          style: new TextStyle(decoration: TextDecoration.underline),
        ),
      ),
    ));

    columnChildren.add(new _InstructionStep(
      3,
      new Text('Copy and paste your API key'),
    ));

    columnChildren.add(new TextFormField(
      autocorrect: false,
      decoration: const InputDecoration(
        labelText: 'Username',
      ),
    ));

    columnChildren.add(new TextFormField(
      autocorrect: false,
      decoration: const InputDecoration(
        labelText: 'API Key',
        helperText: 'e.g. 1ca1d165e973d7f8d35b7deb7a2ae54c',
      ),
    ));

    columnChildren.add(new Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: new RaisedButton(
        child: const Text('SAVE & TEST'),
        onPressed: () {
          _log.fine('Pressed SAVE & TEST');
        },
      ),
    ));

    return new Scaffold(
      appBar: new AppBar(title: const Text('Login')),
      body: new SingleChildScrollView(
        padding: new EdgeInsets.all(10.0),
        child: new Form(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: columnChildren,
          ),
        ),
      ),
    );
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
