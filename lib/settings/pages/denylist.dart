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
  TextEditingController textController = TextEditingController();
  PersistentBottomSheetController<String> sheetController;

  @override
  void initState() {
    super.initState();
    db.denylist.addListener(() async {
      denylist = await db.denylist.value;
      if (mounted) {
        setState(() {});
      }
    });
    db.denylist.value.then((list) {
      if (mounted) {
        setState(() => denylist = list);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Future<void> addTags(BuildContext context, {int edit}) async {
      setFocusToEnd(textController);
      if (isSearching) {
        if (editing != null) {
          if (textController.text.trim().isNotEmpty) {
            denylist[editing] = textController.text.trim();
          } else {
            denylist.removeAt(editing);
          }
          db.denylist.value = Future.value(denylist);
          sheetController?.close();
        } else {
          if (textController.text.trim().isNotEmpty) {
            denylist.add(textController.text.trim());
            db.denylist.value = Future.value(denylist);
            sheetController?.close();
          }
        }
      } else {
        if (edit != null) {
          editing = edit;
          textController.text = denylist[editing];
        } else {
          textController.text = '';
        }
        sheetController = Scaffold.of(context).showBottomSheet((context) {
          return Container(
            padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TagInput(
                controller: textController,
                labelText: 'Add to blacklist',
                onSubmit: (_) => addTags(context),
              ),
            ]),
          );
        });
        setState(() {
          isSearching = true;
        });
        sheetController.closed.then((a) {
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
          onTap: () => wikiSheet(context: context, tag: tagToName(tag)),
          onLongPress: () => wikiSheet(context: context, tag: tagToName(tag)),
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
                padding: EdgeInsets.only(top: 4, bottom: 4, right: 8, left: 6),
                child: Text(tagToCard(tag)),
              ),
            ],
          ),
        ),
      );
    }

    Widget body() {
      if (denylist.isEmpty) {
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
        padding: EdgeInsets.only(bottom: 30),
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
                        children: Tagset.parse(denylist.elementAt(index))
                            .map((tag) => cardWidget(tag.toString()))
                            .toList(),
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
                              value: 'wiki',
                              child: PopTile(
                                  title: 'Wiki', icon: Icons.info_outline),
                            ),
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
                              case 'wiki':
                                wikiSheet(
                                    context: context,
                                    tag: tagToName(denylist[index]));
                                break;
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
              onPressed: () =>
                  wikiSheet(context: context, tag: 'e621:blacklist'),
            )
          ],
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.multiline,
          maxLines: null,
        ),
        actions: <Widget>[
          TextButton(
            child: Text('CANCEL'),
            onPressed: Navigator.of(context).pop,
          ),
          TextButton(
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
