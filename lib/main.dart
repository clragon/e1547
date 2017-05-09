import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class ZoomableImage extends StatefulWidget {
  ZoomableImage(this.imageProvider, {Key key}) : super(key: key);

  final ImageProvider imageProvider;

  @override
  _ZoomableImageState createState() => new _ZoomableImageState(imageProvider);
}

class _ZoomableImageState extends State<ZoomableImage> {
  _ZoomableImageState(this.imageProvider);

  final ImageProvider imageProvider;

  Offset _startingFocalPoint;
  Offset _previousOffset;
  Offset _offset = Offset.zero;

  double _previousZoom;
  double _zoom = 1.0;

  void _handleScaleStart(ScaleStartDetails d) {
    setState(() {
      _startingFocalPoint = d.focalPoint;
      _previousOffset = _offset;
      _previousZoom = _zoom;
    });
  }

  void _handleScaleUpdate(ScaleUpdateDetails d) {
    setState(() {
      _zoom = _previousZoom * d.scale;

      // Ensure that item under the focal point stays in the same place despite zooming
      final Offset normalizedOffset =
          (_startingFocalPoint - _previousOffset) / _previousZoom;
      _offset = d.focalPoint - normalizedOffset * _zoom;
    });
  }

  @override
  Widget build(BuildContext ctx) {
    return new GestureDetector(
      child: new CustomPaint(
          painter: new _ZoomableImagePainter(offset: _offset, zoom: _zoom)),
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
    );
  }
}

class _ZoomableImagePainter extends CustomPainter {
  const _ZoomableImagePainter({this.offset, this.zoom});

  final Offset offset;
  final double zoom;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        offset & (size * zoom), new Paint()..color = const Color(0xFF00FF00));
  }

  @override
  bool shouldRepaint(_ZoomableImagePainter old) {
    return old.offset != offset || old.zoom != zoom;
  }
}

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
        onTap: () {
          print("tapped post ${post['id']}");
          Navigator.of(context).push(new MaterialPageRoute<Null>(
            builder: (context) {
              return new ZoomableImage(new NetworkImage(post['sample_url']));
            },
          ));
        },
        child: new Card(
            child: new Center(
                child: new Image.network(post['preview_url'],
                    fit: BoxFit.cover))));
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
            "https://e621.net/post/index.json?page=1&tags=photonoko&limit=30"))
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
    var index = new GridView.builder(
      controller: new ScrollController(),
      gridDelegate: new SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 150.0,
      ),
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
    widgets.add(_offline
        ? new IconButton(
            icon: new Icon(Icons.cloud_off),
            tooltip: "Reconnect",
            onPressed: () {
              print("pressed the cloud_off icon");
              _offline = false;
              _loadPosts();
            })
        : new IconButton(
            icon: new Icon(Icons.refresh),
            tooltip: "Refresh",
            onPressed: () {
              print("pressed the reload icon");
              _offline = false;
              _loadPosts();
            }));

    return new AppBar(title: new Text("e1547"), actions: widgets);
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
          Scaffold.of(context).showBottomSheet((context) => new TextField());
        },
        child: new Icon(Icons.search));
  }
}
