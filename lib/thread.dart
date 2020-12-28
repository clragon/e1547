import 'dart:async' show Future;

import 'package:e1547/client.dart' show client;
import 'package:e1547/interface.dart';
import 'package:e1547/posts_page.dart';
import 'package:e1547/settings.dart';
import 'package:e1547/threads_page.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Reply {
  Map raw;

  int id;
  int creatorID;
  String body;
  String creation;
  String update;

  Reply.fromRaw(this.raw) {
    id = raw['id'] as int;
    creatorID = raw['creator_id'] as int;
    body = raw['body'] as String;
    creation = raw['created_at'] as String;
    update = raw['updated_at'] as String;
  }
}

class ThreadPreview extends StatelessWidget {
  final Thread thread;
  final VoidCallback onPressed;

  ThreadPreview(
    this.thread, {
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Widget title() {
      return Row(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
              child: Text(
                thread.title,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                margin: EdgeInsets.only(left: 22, top: 8, bottom: 8, right: 16),
                child: Text(
                  thread.posts.toString(),
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 0,
                  bottom: 8,
                ),
                child: Text(
                  getAge(thread.updated),
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          )
        ],
      );
    }

    return Card(
        child: InkWell(
            onTap: this.onPressed,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Center(child: title()),
                ),
                () {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [],
                  );
                }(),
              ],
            )));
  }
}

class ThreadWidget extends StatefulWidget {
  final Thread thread;

  ThreadWidget(this.thread);

  @override
  State createState() => _ThreadWidgetState();
}

class _ThreadWidgetState extends State<ThreadWidget> {
  bool _loading = true;
  ReplyProvider provider;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    provider = ReplyProvider(thread: widget.thread);
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
        onLoading: Text('Loading thread'),
        onEmpty: Text('Failed to load!'),
        isLoading: _loading,
        isEmpty: (!_loading && provider.replies.length == 0),
        child: SmartRefresher(
          controller: _refreshController,
          header: ClassicHeader(
            refreshingText: 'Refreshing...',
            completeText: 'Refreshed thread!',
          ),
          onRefresh: () async {
            await provider.loadNextPage(reset: true);
            _refreshController.refreshCompleted();
          },
          physics: BouncingScrollPhysics(),
          child: ListView.builder(
            itemBuilder: _itemBuilder,
            itemCount: provider.replies.length,
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
        onPressed: () => sendReply(context, widget.thread),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.thread.title),
      ),
      body: body(),
      floatingActionButton: FutureBuilder(
        future: client.hasLogin(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data) {
            return fab();
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Widget replyWidget(Reply reply) {
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
                                reply.creatorID.toString(),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                    MaterialPageRoute<Null>(builder: (context) {
                                  return SearchPage(
                                      tags:
                                          'user:${reply.creatorID.toString()}');
                                }));
                              },
                            ),
                          ),
                          Text(
                            () {
                              String time = ' • ${getAge(reply.creation)}';
                              if (DateTime.parse(reply.creation) !=
                                  DateTime.parse(reply.update)) {
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
                              child: dTextField(context, reply.body),
                            ),
                          ),
                          FutureBuilder(
                            future: db.credentials.value,
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.data.username ==
                                      reply.creatorID.toString()) {
                                return Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: InkWell(
                                    customBorder: CircleBorder(),
                                    child: Icon(
                                      Icons.edit,
                                      size: 18,
                                    ),
                                    onTap: () => sendReply(
                                        context, widget.thread,
                                        reply: reply),
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
              if (await client.hasLogin()) {
                String body = reply.body;
                body = body
                    .replaceAllMapped(
                        RegExp(
                            r'\[quote\]".*?":/user/show/[0-9]* said:.*\[\/quote\]',
                            dotAll: true),
                        (match) => '')
                    .trim();
                body =
                    '[quote]"${reply.creatorID.toString()}":/users/${reply.creatorID} said:\n$body[/quote]\n';
                sendReply(context, widget.thread, text: body);
              }
            },
          ),
          Divider(),
        ],
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, int item) {
    if (item == provider.replies.length - 1) {
      provider.loadNextPage();
    }

    if (item < provider.replies.length) {
      return replyWidget(provider.replies[item]);
    }
    return null;
  }
}

class ReplyProvider extends DataProvider<Reply> {
  final Thread thread;
  List<Reply> get replies => super.items;

  ReplyProvider({@required this.thread})
      : super.extended(extendedProvider: (search, pages) async {
          String cursor;
          pages.length == 0
              ? cursor = 'a0'
              : cursor =
                  'a${pages.last.reduce((value, element) => (value.id > element.id) ? value : element).id.toString()}';
          List<Reply> replies = await client.replies(thread, cursor);
          replies.sort((one, two) => DateTime.parse(one.creation)
              .compareTo(DateTime.parse(two.creation)));
          return replies;
        });
}

Future<bool> sendReply(BuildContext context, Thread thread,
    {String text, Reply reply}) async {
  bool sent = false;
  await Navigator.of(context).push(MaterialPageRoute<Null>(builder: (context) {
    return TextEditor(
      title: 'reply to ${thread.title}',
      content: text ?? (reply != null ? reply.body : null),
      validator: (context, text) async {
        if (text.isNotEmpty) {
          Map response;
          if (text != null) {
            // response = await client.postComment(text, post, Reply: reply);
          } else {
            // response = await client.postComment(text, post);
          }
          if (response['code'] == 200 || response['code'] == 204) {
            sent = true;
            return true;
          } else {
            Scaffold.of(context).showSnackBar(SnackBar(
              duration: Duration(seconds: 1),
              content: Text(
                  'Failed to send reply: ${response['code']} : ${response['reason']}'),
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
