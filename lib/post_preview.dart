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

import 'dart:convert' show JsonEncoder;
import 'dart:ui' show Color;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import 'package:logging/logging.dart' show Logger;
import 'package:fullscreen_mode/fullscreen_mode.dart' show FullscreenMode;
import 'package:url_launcher/url_launcher.dart' as url;
import 'package:zoomable_image/zoomable_image.dart' show ZoomableImage;

import 'persistence.dart' as persistence;

import 'src/e1547/post.dart' show Post;

// Preview of a post that appears in lists of posts. Mostly just the image.
class PostPreview extends StatefulWidget {
  PostPreview(this.post, {Key key}) : super(key: key);

  final Post post;

  @override
  PostPreviewState createState() => new PostPreviewState();
}

class PostPreviewState extends State<PostPreview> {
  static final Logger _log = new Logger('PostPreview');

  bool _isFullscreen = false;

  Widget _buildScore() {
    String scoreString = widget.post.score.toString();
    Color c;
    if (widget.post.score > 0) {
      scoreString = '+' + scoreString;
      c = Colors.green;
    } else if (widget.post.score < 0) {
      c = Colors.red;
    }

    return new Text('score: $scoreString', style: new TextStyle(color: c));
  }

  Widget _buildSafetyRating() {
    const colors = const <String, Color>{
      'E': Colors.red,
      'S': Colors.green,
      'Q': Colors.yellow,
    };

    return new Text('rating: ${widget.post.rating}',
        style: new TextStyle(color: colors[widget.post.rating]));
  }

  Widget _buildArtists() {
    return new Text(widget.post.artist.join('+'));
  }

  Widget _buildImagePreview(BuildContext ctx) {
    return new GestureDetector(
        onTap: () async {
          _log.fine('tapped post ${widget.post.id}');

          await Navigator.of(ctx).push(new MaterialPageRoute<Null>(
              builder: (ctx) => new ZoomableImage(
                      new NetworkImage(widget.post.file_url),
                      scale: 4.0, onTap: () {
                    _log.fine(_isFullscreen);
                    _isFullscreen = !_isFullscreen;
                    if (_isFullscreen) {
                      FullscreenMode.setFullscreen();
                    } else {
                      FullscreenMode.setNormal();
                    }
                  })));

          FullscreenMode.setNormal();
        },
        child: new LayoutBuilder(
            builder: (ctx, constraints) => new Image.network(
                widget.post.sample_url,
                // Make the image width as large as possible with the card.
                width: constraints.maxWidth,
                // Make the height so that it keeps the original aspect ratio.
                height: constraints.maxWidth *
                    (widget.post.sample_height / widget.post.sample_width),
                fit: BoxFit.cover)));
  }

  Widget _buildPostInfo(BuildContext ctx) {
    return new Container(
        padding: const EdgeInsets.all(10.0),
        child: new Row(children: <Widget>[
          new Expanded(child: _buildScore()),
          new Expanded(child: _buildSafetyRating()),
          new Expanded(child: _buildArtists()),
        ]));
  }

  Widget _buildButtonBar(BuildContext ctx) {
    return new ButtonTheme.bar(
        child: new ButtonBar(
      alignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        new IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Add post to favorites',
            onPressed: () => _log.fine('pressed fav')),
        new IconButton(
            icon: const Icon(Icons.chat),
            tooltip: 'Go to comments',
            onPressed: () => _log.fine('pressed chat')),
        new IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: 'Open in browser',
            onPressed: () async => url.launch(
                widget.post.url(await persistence.getHost()).toString())),
        new IconButton(
            icon: const Icon(Icons.more_horiz),
            tooltip: 'More options',
            onPressed: () =>
                showDialog(context: ctx, child: new _MoreDialog(widget.post))),
      ],
    ));
  }

  @override
  Widget build(BuildContext ctx) {
    return new Card(
        child: new Column(
      children: <Widget>[
        _buildImagePreview(ctx),
        _buildPostInfo(ctx),
        _buildButtonBar(ctx),
      ],
    ));
  }
}

class _MoreDialog extends StatelessWidget {
  final Post post;
  _MoreDialog(this.post);

  Widget _buildPostInfo(BuildContext ctx) {
    return new ListTile(
      leading: const Icon(Icons.info_outline),
      title: new Text('Info'),
      onTap: () => showDialog(
            context: ctx,
            child: new SimpleDialog(
              title: new Text('post #${post.id} info'),
              children: <Widget>[
                new TextField(
                    maxLines: 10, // TODO: Make this relative to screen size.
                    style: new TextStyle(fontFamily: 'Courier'),
                    controller: new TextEditingController(
                        text:
                            new JsonEncoder.withIndent('  ').convert(post.raw)))
              ],
            ),
          ),
    );
  }

  Widget _buildCopy(BuildContext ctx) {
    return new ListTile(
      leading: const Icon(Icons.content_copy),
      title: new Text('Copy link'),
      onTap: () async {
        await Clipboard.setData(new ClipboardData(
            text: post.url(await persistence.getHost()).toString()));
        Navigator.of(ctx).pop();
      },
    );
  }

  @override
  Widget build(BuildContext ctx) {
    return new SimpleDialog(
        title: new Text('post #${post.id}'),
        children: <Widget>[
          _buildPostInfo(ctx),
          _buildCopy(ctx),
        ]);
  }
}
