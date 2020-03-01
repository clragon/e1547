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

import 'persistence.dart' show db;

class SettingsPage extends StatefulWidget {
  @override
  State createState() => new _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _host;
  bool _hideSwf;
  String _username;

  @override
  void initState() {
    super.initState();
    db.host.value.then((a) async => setState(() => _host = a));
    db.hideSwf.value.then((a) async => setState(() => _hideSwf = a));
    db.username.value.then((a) async => setState(() => _username = a));
  }

  Function() _onTapSiteBackend(BuildContext ctx) {
    return () async {
      String newHost = await showDialog<String>(
          context: ctx,
          builder: (ctx) {
            return new _SiteBackendDialog(_host);
          });

      if (newHost != null) {
        db.host.value = new Future.value(newHost);
        setState(() {
          _host = newHost;
        });
      }
    };
  }

  void _onChangedHideSwf(bool newHideSwf) {
    db.hideSwf.value = new Future.value(newHideSwf);
    setState(() {
      _hideSwf = newHideSwf;
    });
  }

  Function() _onTapSignOut(BuildContext ctx) {
    return () async {
      String username = await db.username.value;
      db.username.value = new Future.value(null);
      db.apiKey.value = new Future.value(null);

      String msg = 'Forgot login details';
      if (username != null) {
        msg = msg + ' for $username';
      }

      Scaffold.of(ctx).showSnackBar(new SnackBar(
        duration: const Duration(seconds: 5),
        content: new Text(msg),
      ));

      setState(() {
        _username = null;
      });
    };
  }

  @override
  Widget build(BuildContext ctx) {
    Widget bodyWidgetBuilder(BuildContext ctx) {
      return new Container(
        padding: const EdgeInsets.all(10.0),
        child: new ListView(
          children: [
            new ListTile(
              title: const Text('Site backend'),
              subtitle: new Text(_host ?? ' '),
              onTap: _onTapSiteBackend(ctx),
            ),
            new CheckboxListTile(
              title: const Text('Hide Flash posts'),
              value: _hideSwf ?? false,
              onChanged: _onChangedHideSwf,
            ),
            new ListTile(
              title: const Text('Sign out'),
              subtitle: new Text(_username ?? ' '),
              onTap: _onTapSignOut(ctx),
            ),
          ],
        ),
      );
    }

    return new Scaffold(
      appBar: new AppBar(title: const Text('Settings')),
      body: new Builder(builder: bodyWidgetBuilder),
    );
  }
}

class _SiteBackendDialog extends StatelessWidget {
  const _SiteBackendDialog(this.host);

  final String host;

  @override
  Widget build(BuildContext ctx) {
    return new SimpleDialog(
      title: const Text('Site backend'),
      children: [
        new RadioListTile<String>(
          value: 'e926.net',
          title: const Text('e926.net'),
          groupValue: host,
          onChanged: Navigator.of(ctx).pop,
        ),
        new RadioListTile<String>(
          value: 'e621.net',
          title: const Text('e621.net'),
          groupValue: host,
          onChanged: Navigator.of(ctx).pop,
        ),
      ],
    );
  }
}
