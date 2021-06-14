import 'package:e1547/interface.dart';
import 'package:e1547/settings.dart';
import 'package:e1547/settings/pages/input.dart';
import 'package:e1547/tag.dart';
import 'package:e1547/wiki.dart';
import 'package:flutter/material.dart';

class DenyListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DenyListPageState();
  }
}

class _DenyListPageState extends State<DenyListPage> {
  Function fabAction;
  List<String> denylist = [];
  TextEditingController textController = TextEditingController();
  PersistentBottomSheetController<String> sheetController;

  Future<void> updateDenylist() async {
    await db.denylist.value.then((value) {
      if (mounted) {
        setState(() => denylist = value);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    db.denylist.addListener(updateDenylist);
    updateDenylist();
  }

  @override
  void dispose() {
    super.dispose();
    db.denylist.removeListener(updateDenylist);
  }

  @override
  Widget build(BuildContext context) {
    void addTags(BuildContext context, [int edit]) {
      void submit(String value, [int edit]) {
        value = value.trim();

        if (edit != null) {
          if (value.isNotEmpty) {
            denylist[edit] = value;
          } else {
            denylist.removeAt(edit);
          }
          db.denylist.value = Future.value(denylist);
          sheetController?.close();
        } else {
          if (value.isNotEmpty) {
            denylist.add(value);
            db.denylist.value = Future.value(denylist);
            sheetController?.close();
          }
        }
      }

      TextEditingController controller =
          TextEditingController(text: edit != null ? denylist[edit] : null);

      sheetController = Scaffold.of(context).showBottomSheet((context) {
        return ListTagEditor(
          controller: controller,
          onSubmit: (value) => submit(value, edit),
          prompt: 'Add to blacklist',
        );
      });

      setState(() {
        fabAction = () => submit(controller.text, edit);
      });

      sheetController.closed.then((_) {
        setState(() {
          fabAction = null;
        });
      });
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
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        direction: Axis.horizontal,
                        children: Tagset.parse(denylist.elementAt(index))
                            .map((tag) => DenyListTagCard(tag.toString()))
                            .toList(),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
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
                                addTags(context, index);
                                break;
                              case 'delete':
                                denylist.removeAt(index);
                                db.denylist.value = Future.value(denylist);
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
        child: fabAction != null ? Icon(Icons.check) : Icon(Icons.add),
        onPressed: () => fabAction != null ? fabAction : addTags(context),
      );
    }

    Widget editor() {
      TextEditingController controller = TextEditingController();
      controller.text = denylist.join('\n');
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
        actions: [
          TextButton(
            child: Text('CANCEL'),
            onPressed: Navigator.of(context).pop,
          ),
          TextButton(
            child: Text('OK'),
            onPressed: () {
              List<String> tags = controller.text.split('\n');
              tags = tags.map((e) => e.trim()).toList();
              tags.removeWhere((tag) => tag.isEmpty);
              db.denylist.value = Future.value(tags);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Blacklist'),
        actions: [
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
