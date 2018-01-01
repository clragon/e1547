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

class SettingsPageScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Settings')),
      body: new SettingsPage(),
    );
  }
}

class SettingsPage extends StatefulWidget {
  @override
  SettingsPageState createState() => new SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  final Future<String> _initialHost = persistence.getHost();
  String _host;

  final Future<bool> _initialHideSwf = persistence.getHideSwf();
  bool _hideSwf = false;

  final Future<String> _initialUsername = persistence.getUsername();
  String _username;

  @override
  void initState() {
    super.initState();
    _initialHost.then((h) => setState(() {
          _host = h;
        }));
    _initialHideSwf.then((v) => setState(() {
          _hideSwf = v;
        }));
    _initialUsername.then((v) => setState(() {
          _username = v;
        }));
  }

  Function _onTapSiteBackend(BuildContext ctx) {
    return () async {
      String newHost = await showDialog<String>(
        context: ctx,
        child: new _SiteBackendDialog(_host ?? await _initialHost),
      );

      if (newHost != null) {
        persistence.setHost(newHost);
        setState(() {
          _host = newHost;
        });
      }
    };
  }

  void _onChangedHideSwf(bool newValue) {
    persistence.setHideSwf(newValue);
    setState(() {
      _hideSwf = newValue;
    });
  }

  Function _onTapSignOut(BuildContext ctx) {
    return () {
      persistence.setUsername(null);
      persistence.setApiKey(null);

      Scaffold.of(ctx).showSnackBar(new SnackBar(
            duration: const Duration(seconds: 5),
            content: new Text('Forgot login details for $_username'),
          ));
    };
  }

  @override
  Widget build(BuildContext ctx) {
    return new Container(
      padding: const EdgeInsets.all(10.0),
      child: new ListView(
        children: [
          new ListTile(
            title: new Text('Site backend'),
            subtitle: _host != null ? new Text(_host) : null,
            onTap: _onTapSiteBackend(ctx),
          ),
          new CheckboxListTile(
            title: new Text('Hide Flash posts'),
            value: _hideSwf,
            onChanged: _onChangedHideSwf,
          ),
          new ListTile(
            title: new Text('Sign out'),
            subtitle: _username != null ? new Text(_username) : null,
            onTap: _onTapSignOut(ctx),
          ),
        ],
      ),
    );
  }
}

class _SiteBackendDialog extends StatefulWidget {
  const _SiteBackendDialog(this.host);

  final String host;

  @override
  _SiteBackendDialogState createState() => new _SiteBackendDialogState();
}

class _SiteBackendDialogState extends State<_SiteBackendDialog> {
  @override
  Widget build(BuildContext ctx) {
    return new SimpleDialog(
      title: new Text('Site backend'),
      children: [
        new RadioListTile<String>(
          value: 'e926.net',
          title: new Text('e926.net'),
          groupValue: widget.host,
          onChanged: Navigator.of(ctx).pop,
        ),
        new RadioListTile<String>(
          value: 'e621.net',
          title: new Text('e621.net'),
          groupValue: widget.host,
          onChanged: Navigator.of(ctx).pop,
        ),
      ],
    );
  }
}
