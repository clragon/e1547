import 'package:e1547/comments/comment.dart';
import 'package:e1547/dtextfield/dtext_field.dart';
import 'package:e1547/interface/page_loader.dart';
import 'package:e1547/posts/post.dart';
import 'package:e1547/posts/posts_page.dart';
import 'package:e1547/services/client.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/util/age_string.dart';
import 'package:e1547/util/provider.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
      return PageLoader(
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
                                  color: Colors.grey[600],
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
                              String time =
                                  ' • ${getAge(DateTime.parse(comment.creation))}';
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
                              child: DTextField(comment.body),
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
      : super(provider: ((search, page) => client.comments(postID, page)));

  /*
  provider: provider ??
    (search, page, {pages}) async {
      String cursor;
      if (pages.length == 0) {
        cursor = 'a0';
      } else {
        cursor =
            'a${pages.last.reduce((value, element) => (value.id > element.id) ? value : element).id.toString()}';
      }
      List<Comment> comments =
          await client.comments(postID, cursor);
      comments.sort((one, two) => DateTime.parse(one.creation)
          .compareTo(DateTime.parse(two.creation)));
      return comments;
    }
   */
}
