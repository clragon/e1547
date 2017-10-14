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

  Future<bool> _initialHideSwf = persistence.getHideSwf();
  bool _hideSwf = false;

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
    _initialHost.then((h) => setState(() {
          _host = h;
        }));
    _initialHideSwf.then((v) => setState(() {
          _hideSwf = v;
        }));
  }

  Widget _buildBody(BuildContext ctx) {
    Widget body = new ListView(children: [
      new ListTile(
          title: const Text('Site backend'),
          subtitle: _host != null ? new Text(_host) : null,
          onTap: () async {
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
          }),
      new CheckboxListTile(
        title: const Text('Hide Flash posts'),
        value: _hideSwf,
        onChanged: (v) {
          persistence.setHideSwf(v);
          setState(() {
            _hideSwf = v;
          });
        },
      ),
    ]);

    return new Container(padding: new EdgeInsets.all(10.0), child: body);
  }
}

class _SiteBackendDialog extends StatefulWidget {
  _SiteBackendDialog(this.host);
  final String host;

  @override
  _SiteBackendDialogState createState() => new _SiteBackendDialogState();
}

class _SiteBackendDialogState extends State<_SiteBackendDialog> {
  @override
  Widget build(BuildContext ctx) {
    return new SimpleDialog(
      title: const Text('Site backend'),
      children: [
        new RadioListTile<String>(
          value: 'e926.net',
          title: const Text('e926.net'),
          groupValue: widget.host,
          onChanged: Navigator.of(ctx).pop,
        ),
        new RadioListTile<String>(
          value: 'e621.net',
          title: const Text('e621.net'),
          groupValue: widget.host,
          onChanged: Navigator.of(ctx).pop,
        ),
      ],
    );
  }
}
