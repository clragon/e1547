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

import 'package:logging/logging.dart' show Logger;

import 'post_preview.dart' show PostPreview;
import 'persistence.dart' as persistence;

import 'vars.dart' as vars;

import 'src/e1547/e1547.dart' as e1547;

e1547.Client _client = new e1547.Client();

const int _STARTING_PAGE = 1; // Pages are 1-indexed

class PostsPage extends StatefulWidget {
  @override
  _PostsPageState createState() => new _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  final Logger _log = new Logger('PostsPage');

  // Current tags being displayed or searched.
  String _tags = "";
  // Current posts being displayed.
  List<e1547.Post> _posts = [];
  int _page = _STARTING_PAGE;

  // If we're currently offline, meaning a request has failed.
  bool _offline = false;

  @override
  void initState() {
    super.initState();
    _log.info("Performing initial search");
    _loadNextPage();
  }

  _onSearch(String tags) {
    persistence.setTags(tags);
    _tags = tags;
    _page = _STARTING_PAGE;
    _posts.clear();
    _loadNextPage();
  }

  _loadNextPage() async {
    _offline = false; // Let's be optimistic. Doesn't update UI until setState()
    try {
      _client.host = await persistence.getHost() ?? vars.DEFAULT_ENDPOINT;
      _tags = await persistence.getTags() ?? _tags;
      List newPosts = await _client.posts(_tags, _page);
      setState(() {
        _posts.addAll(newPosts);
      });
      _page++;
    } catch (e) {
      _log.info("Going offline: $e", e);
      setState(() {
        _offline = true;
      });
    }
  }

  Widget _body() {
    var index = new ListView.builder(
      itemBuilder: (ctx, i) {
        _log.fine("loading post $i");
        if (i < _posts.length) {
          return new PostPreview(_posts[i]);
        } else if (i == _posts.length) {
          return new RaisedButton(
            child: new Text("load more"),
            onPressed: _loadNextPage,
          );
        } else {
          return null;
        }
      },
    );

    return index;
  }

  AppBar _buildAppBar(BuildContext ctx) {
    List<Widget> widgets = [];

    widgets.add(_offline
        ? new IconButton(
            icon: const Icon(Icons.cloud_off),
            tooltip: "Reconnect",
            onPressed: () => _onSearch(_tags))
        : new IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh",
            onPressed: () => _onSearch(_tags)));

    widgets.add(new PopupMenuButton<String>(
        child: new IconButton(
            icon: const Icon(Icons.sort),
            disabledColor: Colors.white,
            onPressed: null),
        itemBuilder: (ctx) => <PopupMenuEntry<String>>[
              new PopupMenuItem(child: new Text("New"), value: ""),
              new PopupMenuItem(child: new Text("Score"), value: "order:score"),
              new PopupMenuItem(
                  child: new Text("Favorites"), value: "order:favcount")
            ],
        onSelected: (String orderTag) {
          _tags = (orderTag +
                  ' ' +
                  // Strip out all order:* tags
                  _tags.replaceAll(new RegExp(r'order:\w+\b'), ""))
              .trimLeft();

          _onSearch(_tags);
        }));

    return new AppBar(title: new Text(vars.APP_NAME), actions: widgets);
  }

  @override
  Widget build(BuildContext ctx) {
    return new Scaffold(
      appBar: _buildAppBar(ctx),
      body: _body(),
      drawer: new Drawer(
          child: new ListView(children: [
        new UserAccountsDrawerHeader(
            // TODO: account name and email
            accountName: new Text("<username>"),
            accountEmail: new Text("<email>")),
        new ListTile(
            leading: const Icon(Icons.settings),
            title: new Text('Settings'),
            onTap: () {
              Navigator.of(ctx)
                ..pop()
                ..push(new MaterialPageRoute<Null>(
                    builder: (ctx) => new _SettingsPage()));
            }),
        new AboutListTile(icon: const Icon(Icons.help)),
      ])),
      floatingActionButton: new FloatingActionButton(
          child: const Icon(Icons.search),
          onPressed: () => Navigator
                  .of(ctx)
                  .push(new MaterialPageRoute<String>(
                      builder: (ctx) => new _TagEntryPage(_tags)))
                  .then((t) {
                _log.fine("edited tags: '$t'");
                if (t != null && t != _tags) {
                  _onSearch(t);
                }
              }).catchError((e) => _log.warning(e))),
    );
  }
}

class _TagEntryPage extends StatefulWidget {
  final String tags;
  _TagEntryPage(this.tags);

  @override
  _TagEntryPageState createState() => new _TagEntryPageState();
}

class _TagEntryPageState extends State<_TagEntryPage> {
  TextEditingController _controller;

  @override
  Widget build(BuildContext ctx) {
    _controller ??= new TextEditingController(text: widget.tags)
      ..selection = new TextSelection(
          baseOffset: widget.tags.length, extentOffset: widget.tags.length);

    return new Scaffold(
        appBar: new AppBar(title: new Text("tags")),
        body: new Container(
            padding: new EdgeInsets.all(10.0),
            child: new Column(children: <Widget>[
              new TextField(
                  autofocus: true,
                  maxLines: 50,
                  controller: _controller,
                  onSubmitted: (t) => Navigator.of(ctx).pop(t)),
              new Row(
                children: <Widget>[
                  new FlatButton(
                    child: new Text("cancel"),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                  new RaisedButton(
                    child: new Text("save"),
                    onPressed: () =>
                        Navigator.of(ctx).pop(_controller.value.text),
                  ),
                ],
              ),
            ])));
  }
}

class _SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => new _SettingsPageState();
}

class _SettingsPageState extends State<_SettingsPage> {
  Future<String> _initialHost = persistence.getHost();

  TextEditingController _hostController;

  Widget _buildAppBar(BuildContext ctx) =>
      new AppBar(title: new Text("Settings"), actions: <Widget>[
        new IconButton(
            icon: const Icon(Icons.check),
            tooltip: "Save changes",
            onPressed: () async {
              persistence.setHost((await _hostController).value.text);
              Navigator.of(ctx).pop();
            })
      ]);

  Widget _buildBody(BuildContext ctx) {
    _initialHost.then((String host) {
      if (host == null) {
        host = vars.DEFAULT_ENDPOINT;
      }
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
