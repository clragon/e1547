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

import 'package:flutter/material.dart';

import 'package:logging/logging.dart' show Logger;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static final Logger _log = new Logger('LoginPage');

  bool _hasApiKey = false;

  @override
  Widget build(BuildContext ctx) {
    List<Widget> columnChildren = [];

    Widget hasApiKeyCheckbox = new CheckboxListTile(
      title: const Text('I have an API key'),
      value: _hasApiKey,
      onChanged: (b) {
        setState(() {
          _hasApiKey = b;
        });
      },
    );

    columnChildren.add(hasApiKeyCheckbox);

    if (_hasApiKey) {
      columnChildren.add(new TextFormField(
        autocorrect: false,
        decoration: const InputDecoration(
          labelText: 'API Key',
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
    } else {
      columnChildren.add(new TextFormField(
        decoration: const InputDecoration(
          labelText: 'Username',
        ),
      ));

      columnChildren.add(new TextFormField(
        obscureText: true,
        autocorrect: false,
        decoration: const InputDecoration(
          labelText: 'Password',
        ),
      ));

      columnChildren.add(const Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: const Text(
            'Your credentials will be used to request an API key. '
                'Your password will not be stored.',
          )));

      columnChildren.add(new Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: new RaisedButton(
          child: const Text('LOGIN'),
          onPressed: () {
            _log.fine('Pressed LOGIN');
          },
        ),
      ));
    }

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
