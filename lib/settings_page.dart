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
import 'package:flutter/widgets.dart';

import 'persistence.dart' as persistence;
import 'vars.dart' as vars;

class SettingsPage extends StatefulWidget {
  @override
  SettingsPageState createState() => new SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  Future<String> _initialHost = persistence.getHost();

  TextEditingController _hostController;

  Widget _buildAppBar(BuildContext ctx) =>
      new AppBar(title: new Text('Settings'), actions: <Widget>[
        new IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save changes',
            onPressed: () async {
              persistence.setHost((await _hostController).value.text);
              Navigator.of(ctx).pop();
            })
      ]);

  Widget _buildBody(BuildContext ctx) {
    _initialHost.then((String host) {
      assert(host != null); // set in persistence.dart
      setState(() {
        _hostController ??= new TextEditingController(text: host)
          ..selection =
              new TextSelection(baseOffset: 0, extentOffset: host.indexOf('.'));
      });
    });
    return new Container(
        padding: new EdgeInsets.all(10.0),
        child: _hostController == null
            ? new Container()
            : new TextField(autofocus: true, controller: _hostController));
  }

  @override
  Widget build(BuildContext ctx) {
    return new Scaffold(
      appBar: _buildAppBar(ctx),
      body: _buildBody(ctx),
    );
  }
}
