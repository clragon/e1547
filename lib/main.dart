import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'src/zoomable_image/zoomable_image.dart';

void main() {
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
              print("tapped post ${post['id']}");
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
            const IconButton(icon: const Icon(Icons.favorite)),
            const IconButton(icon: const Icon(Icons.chat)),
            new Text(post['rating']),
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
  HttpClient _http = new HttpClient();

  List<Map> _posts = [];

  bool _offline = false;

  String tags = "";

  Future<Null> _loadPostsIfNotAlreadyLoaded() async {
    if (!_posts.isEmpty) {
      return;
    }

    if (_offline) {
      return;
    }

    _loadPosts();
  }

  Future<Null> _loadPosts() async {
    // TODO: detect network failures => offline
    HttpClientResponse response = await _http
        .getUrl(Uri.parse(
            "https://e621.net/post/index.json?page=1&tags=$tags&limit=5"))
        .then((HttpClientRequest req) => req.close(), onError: (e) {
      print("error with request: $e");
    });

    setState(() {
      _offline = response == null;
    });
    if (_offline) {
      return;
    }

    var body = new StringBuffer();
    await response.transform(UTF8.decoder).forEach((s) => body.write(s));

    var posts = JSON.decode(body.toString());
    setState(() => this._posts = posts);
  }

  void _onSearch(String tags) {
    this.tags = tags;
    _loadPosts();
  }

  Widget _body() {
    var index = new ListView.builder(
      itemBuilder: (ctx, i) {
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
            onPressed: () {
              print("pressed the cloud_off icon");
              _offline = false;
              _loadPosts();
            })
        : new IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh",
            onPressed: () {
              print("pressed the reload icon");
              _offline = false;
              _loadPosts();
            }));

    return new AppBar(title: const Text("e1547"), actions: widgets);
  }

  @override
  Widget build(BuildContext context) {
    _loadPostsIfNotAlreadyLoaded();
    return new MaterialApp(
        title: 'e1547',
        theme: new ThemeData.dark(),
        home: new Scaffold(
          appBar: _buildAppBar(),
          body: _body(),
          drawer: new Drawer(
              child: new ListView(children: [
            new UserAccountsDrawerHeader(
                // TODO: account name and email
                accountName: new Text("perlatus"),
                accountEmail: new Text("perlatus@vczf.io")),
            new AboutListTile(),
          ])),
          floatingActionButton: new _SearchFab(
            onSearch: _onSearch,
            controller: new TextEditingController(text: tags),
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
