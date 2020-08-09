import 'dart:async' show Future;

import 'package:e1547/client.dart' show client;
import 'package:e1547/interface.dart';
import 'package:e1547/persistence.dart';
import 'package:e1547/post.dart' show Post;
import 'package:e1547/posts_page.dart';
import 'package:e1547/tag.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
  final Post post;
  CommentsWidget(this.post);

  @override
  State createState() => _CommentsWidgetState();
}

class _CommentsWidgetState extends State<CommentsWidget> {
  bool _loading = true;
  ValueNotifier<List<List<Comment>>> _pages = ValueNotifier([]);
  List<Comment> get _comments {
    return _pages.value
        .fold<Iterable<Comment>>(Iterable.empty(), (a, b) => a.followedBy(b))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadNextPage();
  }

  Future<void> _loadNextPage({bool reset = false}) async {
    int page = reset ? 0 : _pages.value.length;
    List<Comment> nextPage = [];
    nextPage.addAll(await client.comments(widget.post.id, page));
    if (reset && nextPage.length != 0) {
      _pages.value.clear();
    }
    _pages.value = List.from(_pages.value..add(nextPage));
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    _pages.addListener(() {
      if (this.mounted) {
        setState(() {
          if (_pages.value.length == 0) {
            _loading = true;
          } else {
            _loading = false;
          }
        });
      }
    });

    Widget body() {
      return Stack(
        children: <Widget>[
          Visibility(
            visible: _loading,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 28,
                    width: 28,
                    child: CircularProgressIndicator(),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Loading comments'),
                  ),
                ],
              ),
            ),
          ),
          SmartRefresher(
            controller: _refreshController,
            header: ClassicHeader(
              refreshingText: 'Refreshing...',
              completeText: 'Refreshed comments!',
            ),
            onRefresh: () async {
              await _loadNextPage(reset: true);
              _refreshController.refreshCompleted();
            },
            physics: BouncingScrollPhysics(),
            child: ListView.builder(
              itemBuilder: _itemBuilder,
              itemCount: _comments.length,
              padding: EdgeInsets.all(10.0),
              physics: BouncingScrollPhysics(),
            ),
          ),
          Visibility(
            visible: (!_loading && _comments.length == 0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 32,
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No comments'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    Widget fab() {
      return FloatingActionButton(
        heroTag: 'float',
        backgroundColor: Theme.of(context).cardColor,
        child: Icon(Icons.comment, color: Theme.of(context).iconTheme.color),
        onPressed: () => sendComment(context, widget.post),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('#${widget.post.id} comments'),
      ),
      body: body(),
      // floatingActionButton: widget.post.isLoggedIn ? fab() : null,
      floatingActionButton: fab(),
    );
  }

  Widget commentWidget(Comment comment) {
    String getAge(String date) {
      Duration duration =
          DateTime.now().difference(DateTime.parse(date).toLocal());

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
            ago = (duration.inSeconds / periods[period - 1]).round();
          } else {
            ago = duration.inSeconds;
          }
          bool single = (ago == 1);
          switch (periods[period - 1] ?? 1) {
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
      return '$ago $measurement ago';
    }

    return Padding(
      padding: EdgeInsets.only(right: 8, left: 8),
      child: Column(
        children: <Widget>[
          GestureDetector(
            child: Row(
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
                            child: InkWell(
                              child: Text(
                                comment.creator,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                    MaterialPageRoute<Null>(builder: (context) {
                                  return SearchPage(
                                      tags: Tagset.parse(
                                          'user:${comment.creator}'));
                                }));
                              },
                            ),
                          ),
                          Text(
                            () {
                              String time = ' • ${getAge(comment.creation)}';
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
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: dTextField(context, comment.body),
                            ),
                          ),
                          FutureBuilder(
                            future: db.username.value,
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.data == comment.creator) {
                                return Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: InkWell(
                                    customBorder: CircleBorder(),
                                    child: Icon(
                                      Icons.edit,
                                      size: 18,
                                    ),
                                    onTap: () => sendComment(
                                        context, widget.post,
                                        comment: comment),
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
            onTap: () async {
              String body = comment.body;
              body = body
                  .replaceAllMapped(
                      RegExp(
                          r'\[quote\]".*?":/user/show/[0-9]* said:.*\[\/quote\]',
                          dotAll: true),
                      (match) => '')
                  .trim();
              sendComment(context, widget.post);
            },
          ),
          Divider(),
        ],
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, int item) {
    for (List<Comment> page in _pages.value) {
      if (page.isEmpty) {
        return null;
      }

      if (item == _comments.length) {
        _loadNextPage();
      }

      if (item < _comments.length) {
        return commentWidget(page[item]);
      }
    }
    return null;
  }
}

Future<bool> sendComment(BuildContext context, Post post,
    {Comment comment}) async {
  bool sent = false;
  await Navigator.of(context).push(MaterialPageRoute<Null>(builder: (context) {
    return TextEditor(
      title: '#${post.id} comment',
      content: comment != null ? comment.body : null,
      validator: (context, text) async {
        if (text.isNotEmpty) {
          Map response;
          if (text != null) {
            response = await client.postComment(text, post, comment: comment);
          } else {
            response = await client.postComment(text, post);
          }
          if (response['code'] == 200 || response['code'] == 204) {
            sent = true;
            return Future.value(true);
          } else {
            Scaffold.of(context).showSnackBar(SnackBar(
              duration: Duration(seconds: 1),
              content: Text(
                  'Failed to send comment: ${response['code']} : ${response['reason']}'),
              behavior: SnackBarBehavior.floating,
            ));
          }
        }
        return Future.value(false);
      },
    );
  }));
  return sent;
}
