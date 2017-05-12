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
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:logging/logging.dart' show Level, Logger, LogRecord;
import 'package:url_launcher/url_launcher.dart' as url show launch;
import 'package:zoomable_image/zoomable_image.dart' show ZoomableImage;

import 'vars.dart';
import 'src/e1547/e1547.dart';

final Logger _log = new Logger('main');

E1547Client _e1547 = new E1547Client()..host = DEFAULT_ENDPOINT;

void main() {
  Logger.root.level = Level.INFO;
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

// Preview of a post that appears in lists of posts. Mostly just the image.
class PostPreview extends StatelessWidget {
  PostPreview(this.post, {Key key}) : super(key: key);

  final Future<Map> post;

  Widget buildImage(BuildContext context, Map post) {
    return new GestureDetector(
        onTap: () {
          if (post != null) {
            _log.fine("tapped post ${post['id']}");
            Navigator.of(context).push(new MaterialPageRoute(
              builder: (context) {
                return new ZoomableImage(new NetworkImage(post['file_url']),
                    scale: 4.0);
              },
            ));
          }
        },
        child: post == null
            ? new Container(height: 300.0, child: const Icon(Icons.help))
            : new Image.network(post['sample_url'], fit: BoxFit.cover));
  }

  Widget buildScore(Map post) {
    if (post == null) {
      return new Text('?');
    }

    int score = post['score'];
    String scoreString = score.toString();
    Color c;
    if (score > 0) {
      scoreString = '+' + scoreString;
      c = Colors.green;
    } else if (score < 0) {
      c = Colors.red;
    }

    return new Text(scoreString, style: new TextStyle(color: c));
  }

  Widget buildSafetyRating(Map post) {
    if (post == null) {
      return new Text('?');
    }

    const colors = const <String, Color>{
      'E': Colors.red,
      'S': Colors.green,
      'Q': Colors.yellow,
    };

    String safety = post['rating'].toUpperCase();
    return new Text(safety, style: new TextStyle(color: colors[safety]));
  }

  Widget buildBar(Map post) {
    return new ButtonTheme.bar(
        child: new ButtonBar(
      alignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        buildScore(post),
        buildSafetyRating(post),
        new IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: "Add post to favorites",
            onPressed: () => _log.fine("pressed fav")),
        new IconButton(
            icon: const Icon(Icons.chat),
            tooltip: "Go to comments",
            onPressed: () => _log.fine("pressed chat")),
        new Text(post == null ? "?" : post['rating'].toUpperCase()),
        new IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: "Open in browser",
            onPressed: () {
              if (post != null) {
                url.launch(_e1547.postUrl(post['id']).toString());
              }
            }),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) => new FutureBuilder(
      future: post,
      builder: (context, snapshot) => new Card(
              child: new Column(children: <Widget>[
            buildImage(context, snapshot.data),
            buildBar(snapshot.data)
          ])));
}

class E1547Home extends StatefulWidget {
  @override
  _E1547HomeState createState() => new _E1547HomeState();
}

class _E1547HomeState extends State<E1547Home> {
  // Current tags being displayed or searched.
  String _tags = "";
  // Current posts being displayed.
  Pagination<Map> _posts = _e1547.posts("");

  // If we're currently offline, meaning a request has failed.
  bool _offline = false;

  // Controller for our list of posts.
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    _log.info("Performing initial search");
    _onSearch(_tags);
  }

  void _onSearch(String tags) {
    _offline = false; // Let's be optimistic. Doesn't update UI until setState()
    try {
      this._tags = tags;
      Pagination<Map> newPosts = _e1547.posts(tags);
      _scrollController.jumpTo(0.0);
      setState(() {
        _posts = newPosts;
      });
    } catch (e) {
      _log.info("Going offline: $e", e);
      setState(() {
        _offline = true;
      });
    }
  }

  Widget _body() {
    var index = new ListView.builder(
      controller: _scrollController,
      itemBuilder: (ctx, i) {
        return new PostPreview(_posts[i]);
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
      controller: new TextEditingController(text: _e1547.host),
      onSubmitted: (String h) {
        _log.info("new host value: $h");
        _e1547.host = h;
        _onSearch(_tags);
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
