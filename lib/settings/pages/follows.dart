import 'package:e1547/follow.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'input.dart';

class FollowingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FollowingPageState();
  }
}

class _FollowingPageState extends State<FollowingPage> {
  List<Follow> follows;
  Function fabAction;
  PersistentBottomSheetController<String> sheetController;
  ScrollController scrollController = ScrollController();

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

  Widget aliasEditor({
    TextEditingController controller,
    @required Function(String value) onSubmit,
  }) {
    controller ??= TextEditingController();
    setFocusToEnd(controller);

    return Padding(
      padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(
          controller: controller,
          autofocus: true,
          maxLines: 1,
          decoration: InputDecoration(
            labelText: 'Follow Alias',
          ),
          onSubmitted: onSubmit,
        )
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    void addTags(BuildContext context, [int edit]) {
      void submit(String value, {int edit}) {
        value = value.trim();
        Follow result = Follow.fromString(value);

        if (edit != null) {
          if (value.isNotEmpty) {
            follows[edit] = result;
          } else {
            follows.removeAt(edit);
          }
          db.follows.value = Future.value(follows);
          sheetController?.close();
        } else {
          if (value.isNotEmpty) {
            follows.add(result);
            db.follows.value = Future.value(follows);
            sheetController?.close();
          }
        }
      }

      TextEditingController controller =
          TextEditingController(text: edit != null ? follows[edit].tags : null);

      sheetController = Scaffold.of(context).showBottomSheet((context) {
        return ListTagEditor(
          controller: controller,
          onSubmit: (value) => submit(value, edit: edit),
          prompt: 'Add to follows',
        );
      });

      setState(() {
        fabAction = () => submit(controller.text, edit: edit);
      });

      sheetController.closed.then((_) {
        setState(() {
          fabAction = null;
        });
      });
    }

    void editAlias(BuildContext context, int edit) {
      void submit(String value, int edit) {
        value = value.trim();
        if (follows[edit].alias != value) {
          if (value.isNotEmpty) {
            follows[edit].alias = value;
          } else {
            follows[edit].alias = null;
          }
          db.follows.value = Future.value(follows);
          sheetController?.close();
        }
      }

      TextEditingController controller =
          TextEditingController(text: follows[edit].title);

      sheetController = Scaffold.of(context).showBottomSheet((context) {
        return aliasEditor(
          controller: controller,
          onSubmit: (value) => submit(value, edit),
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
        controller: scrollController,
        padding: EdgeInsets.only(top: 8, bottom: 30),
        itemCount: follows.length,
        itemBuilder: (BuildContext context, int index) => FollowListTile(
          follow: follows[index],
          onRename: () => editAlias(context, index),
          onEdit: () => addTags(context, index),
          onDelete: () {
            follows.removeAt(index);
            db.follows.value = Future.value(follows);
          },
        ),
        physics: BouncingScrollPhysics(),
      );
    }

    Widget floatingActionButton(BuildContext context) {
      return FloatingActionButton(
        child: fabAction != null ? Icon(Icons.check) : Icon(Icons.add),
        onPressed: () => fabAction != null ? fabAction() : addTags(context),
      );
    }

    Widget editor() {
      TextEditingController controller = TextEditingController();
      controller.text = follows.tags.join('\n');
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Following'),
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
              tags.removeWhere((tag) => tag.trim().isEmpty);
              tags = tags.map((e) => e.trim()).toList();
              db.follows.value = follows.editWith(tags);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    }

    return Scaffold(
      appBar: ScrollingAppbarFrame(
        child: AppBar(
          title: Text('Following'),
          actions: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async => showDialog(
                context: context,
                builder: (context) => editor(),
              ),
            ),
          ],
        ),
        controller: scrollController,
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
