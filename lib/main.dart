import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

void main() {
  runApp(new E1547App());
}

class E1547App extends StatefulWidget {
  @override
  _E1547AppState createState() => new _E1547AppState();
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

  @override
  Widget build(BuildContext context) {
    _loadPosts();
    return new MaterialApp(
        title: 'E1547',
        theme: new ThemeData.dark(),
        home: new Scaffold(
            appBar: new AppBar(title: new Text("E1547")),
            body: new GridView.builder(
                gridDelegate: new SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200.0, // px
                ),
                itemBuilder: (ctx, i) {
                  return new Center(
                      child: _posts.length > i
                          ? new Text(_posts[i]['id'].toString())
                          : new Text(""));
                })));
  }
}
