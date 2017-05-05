import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(new E1547App());
}

// Preview of a post that appears in lists of posts. Mostly just the image.
class PostPreview extends StatelessWidget {
  PostPreview(Map this.post, {Key key}) : super(key: key);

  final Map post;

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
        onTap: () => print("tapped post ${post['id']}"),
        child: new Card(
            child: new Center(
                child: new Image.network(post['sample_url'],
                    fit: BoxFit.fitWidth))));
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

  Future<Null> _loadPosts() async {
    if (!_posts.isEmpty) {
      return;
    }

    if (_offline) {
      return;
    }

    // TODO: detect network failures => offline
    HttpClientResponse response = await _http
        .getUrl(Uri.parse(
            "https://e621.net/post/index.json?page=1&tags=photonoko&limit=5"))
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

  Widget _body() {
    var index = new ListView.builder(
      controller: new ScrollController(),
      itemBuilder: (ctx, i) {
        return _posts.length > i ? new PostPreview(_posts[i]) : null;
      },
    );

    var scroll = index.controller;
    scroll.addListener(() {
      var pos = scroll.position;
      double begin = pos.extentBefore;
      double end = pos.extentBefore + pos.extentInside;
      print("visible: [$begin, $end]");
    });

    return index;
  }

  AppBar _buildAppBar() {
    List<Widget> widgets = [];
    if (_offline) {
      widgets.add(new IconButton(
        icon: new Icon(Icons.cloud_off),
        tooltip: "Reconnect",
        onPressed: () {
          print("pressed the cloud_off icon");
          _offline = false;
          _loadPosts();
        },
      ));
    }

    return new AppBar(title: new Text("e1547"), actions: widgets);
  }

  @override
  Widget build(BuildContext context) {
    _loadPosts();
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
          floatingActionButton: new _SearchFab(),
        ));
  }
}

class _SearchFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new FloatingActionButton(
        onPressed: () {
          print("pressed FAB");
          Scaffold
              .of(context)
              .showBottomSheet((context) => new Text("bottom sheet?"));
        },
        child: new Icon(Icons.search));
  }
}
