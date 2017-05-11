import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:logging/logging.dart' show Level, Logger, LogRecord;

import 'vars.dart';

import 'src/zoomable_image/zoomable_image.dart';
import 'src/e1547/e1547.dart';

final Logger _log = new Logger('main');

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}: ${rec.object??""}');
  });

  runApp(new E1547App());
}

// Preview of a post that appears in lists of posts. Mostly just the image.
class PostPreview extends StatelessWidget {
  PostPreview(Map this.post, {Key key}) : super(key: key);

  final Map post;

  @override
  Widget build(BuildContext context) {
    return new Card(
        child: new Column(
      children: <Widget>[
        new GestureDetector(
            onTap: () {
              _log.fine("tapped post ${post['id']}");
              Navigator.of(context).push(new MaterialPageRoute<Null>(
                builder: (context) {
                  return new ZoomableImage(new NetworkImage(post['file_url']),
                      scale: 4.0);
                },
              ));
            },
            child: new Image.network(post['sample_url'], fit: BoxFit.cover)),
        new ButtonTheme.bar(
            child: new ButtonBar(
          alignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            new IconButton(
                icon: const Icon(Icons.favorite),
                onPressed: () => _log.fine("pressed fav")),
            new IconButton(
                icon: const Icon(Icons.chat),
                onPressed: () => _log.fine("pressed chat")),
            new Text(post['rating'].toUpperCase()),
          ],
        ))
      ],
    ));
  }
}

class E1547App extends StatefulWidget {
  @override
  _E1547AppState createState() => new _E1547AppState();
}

class _E1547AppState extends State<E1547App> {
  E1547Client _e1547 = new E1547Client()..host = DEFAULT_ENDPOINT;

  // Current tags being displayed or searched.
  String _tags = "order:score";
  // Current posts being displayed.
  List<Map> _posts = [];

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

  Future<Null> _onSearch(String tags) async {
    _offline = false; // Let's be optimistic. Doesn't update UI until setState()
    try {
      this._tags = tags;
      List<Map> newPosts = await _e1547.posts(tags);
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
        _log.fine("loading post $i");
        return _posts.length > i ? new PostPreview(_posts[i]) : null;
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: APP_NAME,
        theme: new ThemeData.dark(),
        home: new Scaffold(
          appBar: _buildAppBar(),
          body: _body(),
          drawer: new Drawer(
              child: new ListView(children: [
            new UserAccountsDrawerHeader(
                // TODO: account name and email
                accountName: new Text("<username>"),
                accountEmail: new Text("<email>")),
            _buildHostField(),
            new AboutListTile(),
          ])),
          floatingActionButton: new _SearchFab(
            onSearch: _onSearch,
            controller: new TextEditingController(text: _tags),
          ),
        ));
  }
}

class _SearchFab extends StatelessWidget {
  _SearchFab({
    Key key,
    ValueChanged<String> this.onSearch,
    TextEditingController this.controller,
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
