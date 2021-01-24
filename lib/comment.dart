import 'dart:async' show Future;

import 'package:e1547/client.dart' show client;
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart' show Post;
import 'package:e1547/posts_page.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Comment {
  Map raw;

  int id;
  int creatorID;
  String creator;
  String body;
  int score;
  String creation;
  String update;

  Comment.fromRaw(this.raw) {
    id = raw['id'] as int;
    creatorID = raw['creator_id'] as int;
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
  CommentProvider provider;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    provider = CommentProvider(postID: widget.post.id);
  }

  @override
  Widget build(BuildContext context) {
    provider.pages.addListener(() {
      if (this.mounted) {
        setState(() {
          if (provider.pages.value.length == 0) {
            _loading = true;
          } else {
            _loading = false;
          }
        });
      }
    });

    Widget body() {
      return pageLoader(
        onLoading: Text('Loading comments'),
        onEmpty: Text('No comments'),
        isLoading: _loading,
        isEmpty: (!_loading && provider.comments.length == 0),
        child: SmartRefresher(
          controller: _refreshController,
          header: ClassicHeader(
            refreshingText: 'Refreshing...',
            completeText: 'Refreshed comments!',
          ),
          onRefresh: () async {
            await provider.loadNextPage(reset: true);
            _refreshController.refreshCompleted();
          },
          physics: BouncingScrollPhysics(),
          child: ListView.builder(
            itemBuilder: _itemBuilder,
            itemCount: provider.comments.length,
            padding: EdgeInsets.all(10.0),
            physics: BouncingScrollPhysics(),
          ),
        ),
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
      floatingActionButton: widget.post.isLoggedIn ? fab() : null,
    );
  }

  Widget commentWidget(Comment comment) {
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
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .color
                                      .withOpacity(0.35),
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                    MaterialPageRoute<Null>(builder: (context) {
                                  return SearchPage(
                                      tags: 'user:${comment.creator}');
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
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .color
                                  .withOpacity(0.35),
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
                            future: db.credentials.value,
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.data.username == comment.creator) {
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
              if (widget.post.isLoggedIn) {
                String body = comment.body;
                body = body
                    .replaceAllMapped(
                        RegExp(
                            r'\[quote\]".*?":/user/show/[0-9]* said:.*\[\/quote\]',
                            dotAll: true),
                        (match) => '')
                    .trim();
                body =
                    '[quote]"${comment.creator}":/users/${comment.creatorID} said:\n$body[/quote]\n';
                sendComment(context, widget.post, text: body);
              }
            },
          ),
          Divider(),
        ],
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, int item) {
    if (item == provider.comments.length - 1) {
      provider.loadNextPage();
    }

    if (item < provider.comments.length) {
      return commentWidget(provider.comments[item]);
    }
    return null;
  }
}

class CommentProvider extends DataProvider<Comment> {
  final int postID;
  List<Comment> get comments => super.items;

  CommentProvider({@required this.postID})
      : super.extended(extendedProvider: ((search, pages) async {
          String cursor;
          if (pages.length == 0) {
            cursor = 'a0';
          } else {
            cursor =
                'a${pages.last.reduce((value, element) => (value.id > element.id) ? value : element).id.toString()}';
          }
          List<Comment> comments = await client.comments(postID, cursor);
          comments.sort((one, two) => DateTime.parse(one.creation)
              .compareTo(DateTime.parse(two.creation)));
          return comments;
        }));
}

Future<bool> sendComment(BuildContext context, Post post,
    {String text, Comment comment}) async {
  bool sent = false;
  await Navigator.of(context).push(MaterialPageRoute<Null>(builder: (context) {
    return TextEditor(
      title: '#${post.id} comment',
      content: text ?? (comment != null ? comment.body : null),
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
            return true;
          } else {
            Scaffold.of(context).showSnackBar(SnackBar(
              duration: Duration(seconds: 1),
              content: Text(
                  'Failed to send comment: ${response['code']} : ${response['reason']}'),
              behavior: SnackBarBehavior.floating,
            ));
          }
        }
        return false;
      },
    );
  }));
  return sent;
}
