import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:e1547/thread.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ThreadDetail extends StatefulWidget {
  final Thread thread;

  ThreadDetail(this.thread);

  @override
  State createState() => _ThreadDetailState();
}

class _ThreadDetailState extends State<ThreadDetail> {
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
      return PageLoader(
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
        future: client.hasLogin,
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
                              child: DTextField(msg: reply.body),
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
              if (await client.hasLogin) {
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
