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
    return new Card(
        child: new Center(
          child: new Image.network(post['sample_url'],
            fit: BoxFit.fitWidth)));
  }
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
        .getUrl(Uri.parse("https://e621.net/post/index.json?page=1&tags=photonoko&limit=5"))
        .then((HttpClientRequest req) => req.close());

    var body = new StringBuffer();
    await response.transform(UTF8.decoder).forEach((s) => body.write(s));

    var posts = JSON.decode(body.toString());
    setState(() => this._posts = posts);
  }

  Widget _body() {
    return new ListView.builder(
      itemBuilder: (ctx, i) {
        return _posts.length > i
            ? new PostPreview(_posts[i])
            : null;
      },
    );
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
