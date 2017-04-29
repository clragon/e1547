import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(new E1547App());
}

class E1547App extends StatefulWidget {
  @override
  _E1547AppState createState() => new _E1547AppState();
}

class _E1547GridDelegate extends SliverGridDelegate {
  SliverGridLayout layout;

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    var layout = new SliverGridRegularTileLayout(
      crossAxisCount: 2,
      crossAxisStride: 100.0,
      childCrossAxisExtent: 100.0,
      mainAxisStride: 100.0,
      childMainAxisExtent: 100.0,
    );

    this.layout = layout;
    return layout;
  }

  @override
  bool shouldRelayout(SliverGridDelegate old) => false;
}

class _E1547AppState extends State<E1547App> {
  HttpClient _http = new HttpClient();

  List<Map> _posts = [];

  Future<Null> _loadPosts() async {
    if (!_posts.isEmpty) {
      return;
    }

    HttpClientResponse response = await _http
        .getUrl(Uri.parse("https://e621.net/post/index.json?page=1&limit=20"))
        .then((HttpClientRequest req) => req.close());

    var body = new StringBuffer();
    await response.transform(UTF8.decoder).forEach((s) => body.write(s));

    var posts = JSON.decode(body.toString());
    setState(() => this._posts = posts);
  }

  Widget _body() {
    var delegate = new _E1547GridDelegate();

    var grid = new GridView.builder(
        controller: new ScrollController(),
        gridDelegate: delegate,
        itemBuilder: (ctx, i) {
          return _posts.length > i
              ? new Center(child: new Text(_posts[i]['id'].toString()))
              : null;
        });

    grid.controller.addListener(() {
      if (delegate.layout != null) {
        var offset = grid.controller.offset;
        int first = delegate.layout.getMinChildIndexForScrollOffset(offset);
        int last = delegate.layout.getMaxChildIndexForScrollOffset(offset);
        print("visible: $first, $last");
      }
    });

    return grid;
  }

  @override
  Widget build(BuildContext context) {
    _loadPosts();
    return new MaterialApp(
        title: 'E1547',
        theme: new ThemeData.dark(),
        home: new Scaffold(
            appBar: new AppBar(title: new Text("E1547")), body: _body()));
  }
}
