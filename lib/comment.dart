import 'dart:async' show Future;

import 'package:e1547/pool.dart';
import 'package:flutter/material.dart';

import 'client.dart' show client;
import 'post.dart' show Post;

class Comment {
  Map raw;

  int id;
  String creator;
  String body;
  int score;

  Comment.fromRaw(this.raw) {
    id = raw['id'] as int;
    creator = raw['creator_name'] as String;
    body = raw['body'] as String;
    score = raw['score'] as int;
  }
}

class CommentsPage extends StatelessWidget {
  final Post post;

  CommentsPage(this.post);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('#${post.id} comments')),
      body: CommentsWidget(post),
    );
  }
}

class CommentsWidget extends StatefulWidget {
  const CommentsWidget(this.post, {Key key}) : super(key: key);

  final Post post;

  @override
  State createState() => new _CommentsWidgetState();
}

class _CommentsWidgetState extends State<CommentsWidget> {
  final List<Comment> _comments = [];
  int _page = 0;
  bool _more = true;

  Future<Null> _loadNextPage() async {
    if (_more) {
      List<Comment> newComments =
          await client.comments(widget.post.id, _page++);
      setState(() {
        _comments.addAll(newComments);
      });
      _more = newComments.isNotEmpty;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadNextPage();
  }

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
      itemBuilder: _itemBuilder,
      padding: const EdgeInsets.all(10.0),
      physics: BouncingScrollPhysics(),
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
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
                      Padding(
                        padding: EdgeInsets.only(top: 4, bottom: 4),
                        child: Text(
                          comment.creator,
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: PoolPreview.dTextField(context, comment.body),
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

    if (index < _comments.length) {
      return commentWidget(_comments[index]);
    }

    if (index == _comments.length) {
      if (index == _comments.length) {
        return FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                ],
              );
            } else {
              return Container();
            }
          },
          future: _loadNextPage(),
        );
      }
    }

    return null;
  }
}
