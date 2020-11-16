import 'package:e1547/pool.dart';
import 'package:e1547/posts_page.dart';
import 'package:e1547/wiki_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'client.dart';
import 'interface.dart';
import 'settings.dart' show db;

class FollowingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FollowingPageState();
  }
}

class _FollowingPageState extends State<FollowingPage> {
  List<String> _follows = [];

  @override
  void initState() {
    super.initState();
    db.follows.addListener(() async {
      List<String> follows = await db.follows.value;
      setState(() => _follows = follows);
    });
    db.follows.value.then((a) async => setState(() => _follows = a));
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
                      .push(MaterialPageRoute<Null>(builder: (context) {
                    return PoolPage(pool: p);
                  }));
                } else {
                  Navigator.of(context)
                      .push(MaterialPageRoute<Null>(builder: (context) {
                    return SearchPage(tags: tag);
                  }));
                }
              },
              onLongPress: () => wikiDialog(context, tag, actions: true),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text(tag),
              )));
    }

    Widget body() {
      if (_follows.length == 0) {
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
        itemCount: _follows.length,
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
                        children: () {
                          return [cardWidget(_follows[index])];
                        }(),
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
                              child: popMenuListTile('Search', Icons.search),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: popMenuListTile('Delete', Icons.delete),
                            ),
                          ],
                          onSelected: (value) async {
                            switch (value) {
                              case 'search':
                                if (_follows[index].startsWith('pool:')) {
                                  Pool p = await client.pool(
                                      int.parse(_follows[index].split(':')[1]));
                                  Navigator.of(context).push(
                                      MaterialPageRoute<Null>(
                                          builder: (context) {
                                    return PoolPage(pool: p);
                                  }));
                                } else {
                                  Navigator.of(context).push(
                                      MaterialPageRoute<Null>(
                                          builder: (context) {
                                    return SearchPage(tags: _follows[index]);
                                  }));
                                }
                                break;
                              case 'delete':
                                db.follows.value =
                                    Future.value(_follows..removeAt(index));
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
      TextEditingController controller = TextEditingController();
      PersistentBottomSheetController<String> sheetController;
      ValueNotifier<bool> isSearching = ValueNotifier(false);

      return ValueListenableBuilder(
        valueListenable: isSearching,
        builder: (context, value, child) {
          void submit() {
            if (controller.text.trim().isNotEmpty) {
              db.follows.value =
                  Future.value(_follows..add(controller.text.trim()));
              sheetController?.close();
            }
          }

          return FloatingActionButton(
            child: isSearching.value ? Icon(Icons.check) : Icon(Icons.add),
            onPressed: () async {
              setFocusToEnd(controller);
              if (isSearching.value) {
                submit();
              } else {
                controller.text = '';
                sheetController =
                    Scaffold.of(context).showBottomSheet((context) => Container(
                          padding: EdgeInsets.only(
                              left: 10.0, right: 10.0, bottom: 10),
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                            tagInputField(
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
      controller.text = _follows.join('\n');
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
          FlatButton(
            child: Text('CANCEL'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text('OK'),
            onPressed: () {
              setState(() {
                db.follows.value = Future.value(controller.text.split('\n'));
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
