import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:e1547/thread.dart';
import 'package:flutter/material.dart';

class ThreadDetail extends StatefulWidget {
  final Thread thread;

  ThreadDetail(this.thread);

  @override
  State createState() => _ThreadDetailState();
}

class _ThreadDetailState extends State<ThreadDetail> {
  ReplyProvider provider;

  @override
  void initState() {
    super.initState();
    provider = ReplyProvider(thread: widget.thread);
    provider.pages.addListener(() {
      if (this.mounted) {
        setState(() {});
      }
    });
  }

  Widget replyWidget(Reply reply) {
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
                                reply.creatorId.toString(),
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
                                      tags:
                                          'user:${reply.creatorId.toString()}');
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
                                      reply.creatorId.toString()) {
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
                    '[quote]"${reply.creatorId.toString()}":/users/${reply.creatorId} said:\n$body[/quote]\n';
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
    if (item == provider.items.length - 1) {
      provider.loadNextPage();
    }

    if (item < provider.items.length) {
      return replyWidget(provider.items[item]);
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
        onPressed: () => sendReply(context, widget.thread),
      );
    }

    return RefreshableProviderPage(
      child: ListView.builder(
        itemBuilder: _itemBuilder,
        itemCount: provider.items.length,
        padding: EdgeInsets.all(10.0),
        physics: BouncingScrollPhysics(),
      ),
      appBar: AppBar(
        title: Text(widget.thread.title),
      ),
      provider: provider,
      onLoading: Text('Loading replies'),
      onEmpty: Text('No replies'),
      onError: Text('Failed to load replies'),
      floatingActionButton: FutureBuilder(
        future: client.hasLogin,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data) {
            return fab();
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }
}
