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
import 'package:flutter/rendering.dart';

import 'package:logging/logging.dart' show Level, Logger, LogRecord;

import 'post_preview.dart';
import 'persistence.dart' show getHost, setHost;
import 'vars.dart';

import 'src/e1547/e1547.dart';

final Logger _log = new Logger('main');

E1547Client _e1547 = new E1547Client();

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}: ${rec.object??""}');
  });

  runApp(new MaterialApp(
    title: APP_NAME,
    theme: new ThemeData.dark(),
    routes: <String, WidgetBuilder>{},
    home: new E1547Home(),
  ));
}

const int _STARTING_PAGE = 1; // Pages are 1-indexed

class E1547Home extends StatefulWidget {
  @override
  _E1547HomeState createState() => new _E1547HomeState();
}

class _E1547HomeState extends State<E1547Home> {
  // Current tags being displayed or searched.
  String _tags = "";
  // Current posts being displayed.
  List<Post> _posts = [];
  int _page = _STARTING_PAGE;

  // If we're currently offline, meaning a request has failed.
  bool _offline = false;

  TextEditingController _hostController =
      new TextEditingController(text: _e1547.host);

  @override
  void initState() {
    super.initState();
    _log.info("Performing initial search");
    _loadNextPage();
  }

  _onSearch(String tags) {
    _tags = tags;
    _page = _STARTING_PAGE;
    _posts.clear();
    _loadNextPage();
  }

  _loadNextPage() async {
    _offline = false; // Let's be optimistic. Doesn't update UI until setState()
    try {
      _e1547.host = await getHost() ?? DEFAULT_ENDPOINT;
      List newPosts = await _e1547.posts(_tags, _page);
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

  AppBar _buildAppBar() {
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

    return new AppBar(title: new Text(APP_NAME), actions: widgets);
  }

  Widget _buildHostField() {
    return new TextField(
      controller: _hostController..text = _e1547.host,
      onSubmitted: (String h) {
        _log.info("new host value: $h");
        _e1547.host = h;
        _onSearch(_tags);
        setHost(h);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _buildAppBar(),
      body: _body(),
      drawer: new Drawer(
          child: new ListView(children: [
        new UserAccountsDrawerHeader(
            // TODO: account name and email
            accountName: new Text("<username>"),
            accountEmail: new Text("<email>")),
        _buildHostField(),
        new Divider(),
        new ListTile(
            leading: const Icon(Icons.settings),
            title: new Text('Settings'),
            onTap: () => _log.info('Tapped Settings')),
        new AboutListTile(icon: const Icon(Icons.help)),
      ])),
      floatingActionButton: new _SearchFab(
        onSearch: _onSearch,
        controller: new TextEditingController(text: _tags),
      ),
    );
  }
}

class _SearchFab extends StatelessWidget {
  _SearchFab({
    Key key,
    this.onSearch,
    this.controller,
  })
      : super(key: key);

  final ValueChanged<String> onSearch;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return new FloatingActionButton(
        onPressed: () {
          Scaffold.of(context).showBottomSheet((context) => new TextField(
                autofocus: true,
                controller: controller,
                onSubmitted: onSearch,
              ));
        },
        child: const Icon(Icons.search));
  }
}
