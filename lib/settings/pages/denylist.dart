import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:e1547/wiki.dart';
import 'package:flutter/material.dart';

class DenyListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DenyListPageState();
  }
}

class _DenyListPageState extends State<DenyListPage> {
  int editing;
  bool isSearching = false;
  List<String> denylist = [];
  TextEditingController controller = TextEditingController();
  PersistentBottomSheetController<String> bottomSheetController;

  @override
  void initState() {
    super.initState();
    db.denylist.addListener(() async {
      denylist = await db.denylist.value;
      if (mounted) {
        setState(() {});
      }
    });
    db.denylist.value
        .then((list) => mounted ? setState(() => denylist = list) : () {});
  }

  @override
  Widget build(BuildContext context) {
    Future<void> addTags(BuildContext context, {int edit}) async {
      setFocusToEnd(controller);
      if (isSearching) {
        if (editing != null) {
          if (controller.text.trim().isNotEmpty) {
            denylist[editing] = controller.text.trim();
          } else {
            denylist.removeAt(editing);
          }
          db.denylist.value = Future.value(denylist);
          bottomSheetController?.close();
        } else {
          if (controller.text.trim().isNotEmpty) {
            denylist.add(controller.text.trim());
            db.denylist.value = Future.value(denylist);
            bottomSheetController?.close();
          }
        }
      } else {
        if (edit != null) {
          editing = edit;
          controller.text = denylist[editing];
        } else {
          controller.text = '';
        }
        bottomSheetController = Scaffold.of(context).showBottomSheet((context) {
          return Container(
            padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TagInput(
                controller: controller,
                labelText: 'Add to blacklist',
                onSubmit: (_) => addTags(context),
              ),
            ]),
          );
        });
        setState(() {
          isSearching = true;
        });
        bottomSheetController.closed.then((a) {
          setState(() {
            isSearching = false;
            editing = null;
          });
        });
      }
    }

    Widget cardWidget(String tag) {
      return Card(
          child: InkWell(
              onTap: () => wikiDialog(context, noDash(tag), actions: true),
              onLongPress: () =>
                  wikiDialog(context, noDash(tag), actions: true),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    height: 24,
                    width: 5,
                    decoration: BoxDecoration(
                      color: () {
                        if ('${tag[0]}' == '-') {
                          return Colors.green[300];
                        } else {
                          return Colors.red[300];
                        }
                      }(),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          bottomLeft: Radius.circular(5)),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(top: 4, bottom: 4, right: 8, left: 6),
                    child: Text(noDash(tag.replaceAll('_', ' '))),
                  ),
                ],
              )));
    }

    Widget body() {
      if (denylist.length == 0) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check,
                size: 32,
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Text('Your blacklist is empty'),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: denylist.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Wrap(
                        direction: Axis.horizontal,
                        children: () {
                          List<Widget> rows = [];
                          if (denylist.length > 0) {
                            List<String> tags = denylist[index].split(' ');
                            for (String tag in tags) {
                              if (tag.isEmpty) {
                                continue;
                              }
                              rows.add(cardWidget(tag));
                            }
                            return rows;
                          } else {
                            return [Container()];
                          }
                        }(),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            PopupMenuItem(
                              value: 'edit',
                              child: PopTile(title: 'Edit', icon: Icons.edit),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child:
                                  PopTile(title: 'Delete', icon: Icons.delete),
                            ),
                          ],
                          onSelected: (value) async {
                            switch (value) {
                              case 'edit':
                                addTags(context, edit: index);
                                break;
                              case 'delete':
                                setState(() {
                                  denylist.removeAt(index);
                                  db.denylist.value = Future.value(denylist);
                                });
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
      return FloatingActionButton(
        child: isSearching ? Icon(Icons.check) : Icon(Icons.add),
        onPressed: () => addTags(context),
      );
    }

    Widget editor() {
      TextEditingController controller = TextEditingController();
      controller.text = denylist.join('\n');
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Blacklist'),
            IconButton(
              icon: Icon(Icons.help_outline),
              onPressed: () => wikiDialog(context, 'e621:blacklist'),
            )
          ],
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.multiline,
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
                denylist = controller.text.split('\n');
                List<String> newList = [];
                for (String line in denylist) {
                  if (line.trim().isNotEmpty) {
                    newList.add(line.trim());
                  }
                }
                denylist = newList;
                db.denylist.value = Future.value(denylist);
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Blacklist'),
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
