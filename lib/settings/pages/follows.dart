import 'package:e1547/follow.dart';
import 'package:e1547/interface.dart';
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
  int editing;
  FollowList follows;
  bool isSearching = false;
  TextEditingController textController = TextEditingController();
  PersistentBottomSheetController<String> sheetController;

  Future<void> update() async {
    await db.follows.value.then((value) {
      if (mounted) {
        setState(() => follows = value);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    db.follows.addListener(update);
    update();
  }

  @override
  void dispose() {
    super.dispose();
    db.follows.removeListener(update);
  }

  @override
  Widget build(BuildContext context) {
    Future<void> addTags(BuildContext context, {int edit}) async {
      setFocusToEnd(textController);
      if (isSearching) {
        if (editing != null) {
          if (textController.text.trim().isNotEmpty) {
            follows[editing] = textController.text.trim();
          } else {
            follows.removeAt(editing);
          }
          sheetController?.close();
        } else {
          if (textController.text.trim().isNotEmpty) {
            follows.add(textController.text.trim());
            sheetController?.close();
          }
        }
      } else {
        if (edit != null) {
          editing = edit;
          textController.text = follows[editing];
        } else {
          textController.text = '';
        }
        sheetController = Scaffold.of(context).showBottomSheet((context) {
          return Container(
            padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TagInput(
                controller: textController,
                labelText: 'Add to follows',
                onSubmit: (_) => addTags(context),
              ),
            ]),
          );
        });
        setState(() {
          isSearching = true;
        });
        sheetController.closed.then((_) {
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
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => SearchPage(tags: tag))),
          onLongPress: () => wikiSheet(context: context, tag: tagToName(tag)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Text(tagToTitle(tag)),
              ),
            ],
          ),
        ),
      );
    }

    Widget body() {
      if (follows?.isEmpty ?? true) {
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
        padding: EdgeInsets.only(bottom: 30),
        itemCount: follows.length,
        itemBuilder: (BuildContext context, int index) {
          Widget contextMenu() {
            return Row(
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
                      value: 'edit',
                      child: PopTile(title: 'Edit', icon: Icons.edit),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: PopTile(title: 'Delete', icon: Icons.delete),
                    ),
                  ],
                  onSelected: (value) async {
                    switch (value) {
                      case 'edit':
                        addTags(context, edit: index);
                        break;
                      case 'delete':
                        db.follows.value =
                            Future.value(follows..removeAt(index));
                        break;
                    }
                  },
                ),
              ],
            );
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: <Widget>[
                InkWell(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SearchPage(tags: follows[index]))),
                  onLongPress: () => wikiSheet(
                      context: context, tag: tagToName(follows[index])),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Wrap(
                          direction: Axis.horizontal,
                          children: follows[index]
                              .split(' ')
                              .map((tag) => cardWidget(tag))
                              .toList(),
                        ),
                      ),
                      contextMenu(),
                    ],
                  ),
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
      TextEditingController controller =
          TextEditingController(text: follows.join('\n'));
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
              List<String> tags = controller.text.split('\n');
              tags.removeWhere((tag) => tag.trim().isEmpty);
              follows.edit(tags);
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
            onPressed: () async => showDialog(
              context: context,
              builder: (context) => editor(),
            ),
          ),
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
