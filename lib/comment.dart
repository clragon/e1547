import 'dart:async' show Future;
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:e1547/client.dart' show client;
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart' show Post;

class Comment {
  Map raw;

  int id;
  String creator;
  String body;
  int score;
  String creation;
  String update;

  Comment.fromRaw(this.raw) {
    id = raw['id'] as int;
    creator = raw['creator_name'] as String;
    body = raw['body'] as String;
    score = raw['score'] as int;
    creation = raw['created_at'] as String;
    update = raw['updated_at'] as String;
  }
}

class CommentsWidget extends StatefulWidget {
  const CommentsWidget(this.post, {Key key}) : super(key: key);

  final Post post;

  @override
  State createState() => new _CommentsWidgetState();
}

class _CommentsWidgetState extends State<CommentsWidget> {
  final List<List<Comment>> _pages = [];
  bool _loading = true;

  Future<Null> _loadNextPage() async {
    int p = _pages.length;
    List<Comment> newComments = await client.comments(widget.post.id, p);
    setState(() {
      if (newComments != []) {
        _pages.add(newComments);
      }
      _loading = false;
    });
  }

  RefreshController _refreshController =
  RefreshController(initialRefresh: false);

  void _clearPages() {
    setState(() {
      _loading = true;
      _pages.clear();
      _refreshController.refreshCompleted();
    });
  }

  int _itemCount() {
    int i = 0;
    if (_pages.isEmpty) {
      _loadNextPage();
    }
    for (List<Comment> p in _pages) {
      i += p.length;
    }
    return i;
  }

  Widget body() {
    return new Stack(
      children: <Widget>[
        new Visibility(
          visible: _loading,
          child: new Center(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                new Container(
                  height: 28,
                  width: 28,
                  child: new CircularProgressIndicator(),
                ),
                new Padding(
                  padding: EdgeInsets.all(20),
                  child: new Text('Loading comments'),
                ),
              ],
            ),
          ),
        ),
        SmartRefresher(
          controller: _refreshController,
          header: ClassicHeader(
            completeText: 'refreshing...',
          ),
          onRefresh: _clearPages,
          physics: BouncingScrollPhysics(),
          child: new ListView.builder(
            itemBuilder: _itemBuilder,
            itemCount: _itemCount(),
            padding: const EdgeInsets.all(10.0),
            physics: BouncingScrollPhysics(),
          ),
        ),
        new Visibility(
          visible: (!_loading && _pages.length == 1 && _pages[0].length == 0),
          child: new Center(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                new Icon(
                  Icons.error_outline,
                  size: 32,
                ),
                new Padding(
                  padding: EdgeInsets.all(20),
                  child: new Text('No comments'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('#${widget.post.id} comments'),
      ),
      body: body(),
    );
  }

  Widget commentWidget(Comment comment) {
    return Padding(
      padding: EdgeInsets.only(right: 8, left: 8),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 8, top: 4),
                child: Icon(Icons.person),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 4, bottom: 4),
                          child: Text(
                            comment.creator,
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        Text(
                          () {
                            Duration duration = DateTime.now().difference(
                                DateTime.parse(comment.creation).toLocal());

                            List<int> periods = [
                              1,
                              60,
                              3600,
                              86400,
                              604800,
                              2419200,
                              29030400,
                            ];

                            int ago;
                            String measurement;
                            for (int period = 0; period <= periods.length; period++) {
                              if (period == periods.length || duration.inSeconds < periods[period]) {
                                if (period != 0) {
                                  ago = (duration.inSeconds / periods[period -1]).round();
                                } else {
                                  ago = duration.inSeconds;
                                }
                                bool single = (ago == 1);
                                switch (periods[period -1] ?? 1) {
                                  case 1:
                                    measurement = single ? 'second' : 'seconds';
                                    break;
                                  case 60:
                                    measurement = single ? 'minute' : 'minutes';
                                    break;
                                  case 3600:
                                    measurement = single ? 'hour' : 'hours';
                                    break;
                                  case 86400:
                                    measurement = single ? 'day' : 'days';
                                    break;
                                  case 604800:
                                    measurement = single ? 'week' : 'weeks';
                                    break;
                                  case 2419200:
                                    measurement = single ? 'month' : 'months';
                                    break;
                                  case 29030400:
                                    measurement = single ? 'year' : 'years';
                                    break;
                                }
                                break;
                              }
                            }

                            String time = ' • $ago $measurement ago';
                            if (DateTime.parse(comment.creation) !=
                                DateTime.parse(comment.update)) {
                              time += ' (edited)';
                            }
                            return time;

                          }(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: dTextField(context, comment.body),
                    )
                  ],
                ),
              )
            ],
          ),
          Divider(),
        ],
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, int item) {
    int comments = 0;

    for (int p = 0; p < _pages.length; p++) {
      List<Comment> page = _pages[p];
      if (page.isEmpty) {
        return new Container();
      }

      comments += page.length;

      if (item == comments - 1) {
        if (p + 1 >= _pages.length) {
          _loadNextPage();
        }
      }

      if (item < comments) {
        return commentWidget(page[item]);
      }
    }

    return null;
  }
}
