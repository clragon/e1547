import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/pool.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:e1547/wiki.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FollowingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FollowingPageState();
  }
}

class _FollowingPageState extends State<FollowingPage> {
  List<String> follows = [];

  @override
  void initState() {
    super.initState();
    db.follows.addListener(() async {
      List<String> tags = await db.follows.value;
      if (mounted) {
        setState(() => follows = tags);
      }
    });
    db.follows.value.then((a) async => setState(() => follows = a));
  }

  @override
  Widget build(BuildContext context) {
    Widget cardWidget(String tag) {
      return Card(
          child: InkWell(
              onTap: () async {
                if (tag.startsWith('pool:')) {
                  Pool p = await client.pool(int.parse(tag.split(':')[1]));
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return PoolPage(pool: p);
                  }));
                } else {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return SearchPage(tags: tag);
                  }));
                }
              },
              onLongPress: () => wikiSheet(context: context, tag: tag),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text(tag),
              )));
    }

    Widget body() {
      if (follows.length == 0) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bookmark,
                size: 32,
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Text('You are not following any tags'),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: follows.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [cardWidget(follows[index])],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            PopupMenuItem(
                              value: 'search',
                              child:
                                  PopTile(title: 'Search', icon: Icons.search),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child:
                                  PopTile(title: 'Delete', icon: Icons.delete),
                            ),
                          ],
                          onSelected: (value) async {
                            switch (value) {
                              case 'search':
                                if (follows[index].startsWith('pool:')) {
                                  Pool p = await client.pool(
                                      int.parse(follows[index].split(':')[1]));
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return PoolPage(pool: p);
                                  }));
                                } else {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return SearchPage(tags: follows[index]);
                                  }));
                                }
                                break;
                              case 'delete':
                                db.follows.value =
                                    Future.value(follows..removeAt(index));
                                break;
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                Divider()
              ],
            ),
          );
        },
        physics: BouncingScrollPhysics(),
      );
    }

    Widget floatingActionButton(BuildContext context) {
      PersistentBottomSheetController<String> sheetController;
      ValueNotifier<bool> isSearching = ValueNotifier(false);

      return ValueListenableBuilder(
        valueListenable: isSearching,
        builder: (context, value, child) {
          void submit(String result) {
            result = result.trim();
            if (result.isNotEmpty) {
              db.follows.value = Future.value(follows..add(result));
              sheetController?.close();
            }
          }

          return FloatingActionButton(
            child: isSearching.value ? Icon(Icons.check) : Icon(Icons.add),
            onPressed: () async {
              TextEditingController controller = TextEditingController();
              setFocusToEnd(controller);
              if (isSearching.value) {
                submit(controller.text);
              } else {
                controller.text = '';
                sheetController =
                    Scaffold.of(context).showBottomSheet((context) => Container(
                          padding: EdgeInsets.only(
                              left: 10.0, right: 10.0, bottom: 10),
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                            TagInput(
                                labelText: 'Follow Tag',
                                onSubmit: submit,
                                controller: controller,
                                multiInput: false),
                          ]),
                        ));
                isSearching.value = true;
                sheetController.closed.then((a) {
                  isSearching.value = false;
                });
              }
            },
          );
        },
      );
    }

    Widget editor() {
      TextEditingController controller = TextEditingController();
      controller.text = follows.join('\n');
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Following'),
          ],
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.multiline,
          inputFormatters: [FilteringTextInputFormatter.deny(' ')],
          maxLines: null,
        ),
        actions: <Widget>[
          TextButton(
            child: Text('CANCEL'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('OK'),
            onPressed: () {
              List<String> tags = controller.text.split('\n');
              tags.removeWhere((tag) => tag.trim().isEmpty);
              setState(() {
                db.follows.value = Future.value(tags);
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Following'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (context) => editor(),
                );
              }),
        ],
      ),
      body: body(),
      floatingActionButton: Builder(
        builder: (context) {
          return floatingActionButton(context);
        },
      ),
    );
  }
}
