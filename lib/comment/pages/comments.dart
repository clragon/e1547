import 'package:e1547/comment.dart';
import 'package:e1547/dtext.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';

class CommentsPage extends StatefulWidget {
  final Post post;

  CommentsPage({@required this.post});

  @override
  State createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  CommentProvider provider;

  @override
  void initState() {
    super.initState();
    provider = CommentProvider(postID: widget.post.id);
    provider.pages.addListener(() {
      if (this.mounted) {
        setState(() {});
      }
    });
  }

  Widget commentWidget(Comment comment) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
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
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
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
                              child: DTextField(msg: comment.body),
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
                                return SizedBox.shrink();
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
                    .replaceFirstMapped(
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

  Widget itemBuilder(BuildContext context, int item) {
    if (item == provider.items.length - 1) {
      provider.loadNextPage();
    }

    if (item < provider.items.length) {
      return commentWidget(provider.items[item]);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    Widget fab() {
      return FloatingActionButton(
        heroTag: 'float',
        backgroundColor: Theme.of(context).cardColor,
        child: Icon(Icons.comment, color: Theme.of(context).iconTheme.color),
        onPressed: () => sendComment(context, widget.post),
      );
    }

    return RefreshableProviderPage(
      child: ListView.builder(
        itemBuilder: itemBuilder,
        itemCount: provider.items.length,
        padding: EdgeInsets.all(10.0),
        physics: BouncingScrollPhysics(),
      ),
      appBar: AppBar(
        title: Text('#${widget.post.id} comments'),
      ),
      provider: provider,
      onLoading: Text('Loading comments'),
      onEmpty: Text('No comments'),
      onError: Text('Failed to load comments'),
      floatingActionButton: widget.post.isLoggedIn ? fab() : null,
    );
  }
}
