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

class SettingsPage extends StatefulWidget {
  @override
  SettingsPageState createState() => new SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  Future<String> _initialHost = persistence.getHost();

  String _host;

  @override
  Widget build(BuildContext ctx) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Settings')),
      body: _buildBody(ctx),
    );
  }

  @override
  void initState() {
    super.initState();
    _initialHost.then(_onNewHostSelected);
  }

  Widget _buildBody(BuildContext ctx) {
    Widget body = new Column(children: [
      new RadioListTile<String>(
        value: 'e926.net',
        title: new Text('e926.net'),
        groupValue: _host,
        onChanged: _onNewHostSelected,
      ),
      new RadioListTile<String>(
        value: 'e621.net',
        title: new Text('e621.net'),
        groupValue: _host,
        onChanged: _onNewHostSelected,
      ),
    ]);

    return new Container(padding: new EdgeInsets.all(10.0), child: body);
  }

  void _onNewHostSelected(String host) {
    print('SettingsPageState._onNewHostSelected(host=$host)');
    assert(host != null);

    setState(() {
      _host = host;
    });

    persistence.setHost(host);
  }
}
