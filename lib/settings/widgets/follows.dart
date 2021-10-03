import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FollowingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FollowingPageState();
  }
}

class _FollowingPageState extends State<FollowingPage> with LinkingMixin {
  SheetActionController sheetController = SheetActionController();
  ScrollController scrollController = ScrollController();

  late List<Follow> follows;
  late bool safe;

  void updateFollows() {
    setState(() {
      follows = List.from(settings.follows.value);
    });
  }

  void updateSafety() {
    setState(() {
      safe = client.isSafe;
    });
  }

  @override
  Map<ChangeNotifier, VoidCallback> get initLinks => {
        settings.follows: updateFollows,
        settings.host: updateSafety,
      };

  void addTags(BuildContext context, [int? edit]) {
    void submit(String value, [int? edit]) {
      value = value.trim();
      Follow result = Follow.fromString(value);

      if (edit != null) {
        if (value.isNotEmpty) {
          follows[edit] = result;
        } else {
          follows.removeAt(edit);
        }
        settings.follows.value = follows;
      } else if (value.isNotEmpty) {
        follows.add(result);
        settings.follows.value = follows;
      }
    }

    sheetController.show(
      context,
      SheetTextWrapper(
        submit: (value) => submit(sortTags(value), edit),
        actionController: sheetController,
        textController: TextEditingController(
            text: edit != null ? follows[edit].tags : null),
        builder: (context, controller, submit) => TagInput(
          controller: controller,
          labelText: edit != null ? 'Edit follow' : 'Add to follows',
          submit: submit,
        ),
      ),
    );
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
        settings.follows.value = follows;
      }
    }

    sheetController.show(
      context,
      SheetTextField(
        labelText: 'Follow alias',
        actionController: sheetController,
        textController: TextEditingController(text: follows[edit].title),
        submit: (value) => submit(value, edit),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body() {
      if (follows.isEmpty) {
        return IconMessage(
          icon: Icon(Icons.bookmark),
          title: Text('You are not following any tags'),
        );
      }

      return ListView.builder(
        controller: scrollController,
        physics: BouncingScrollPhysics(),
        padding:
            EdgeInsets.only(top: 8, bottom: kBottomNavigationBarHeight + 24),
        itemCount: follows.length,
        itemBuilder: (BuildContext context, int index) => FollowListTile(
          safe: safe,
          follow: follows[index],
          onRename: () => editAlias(context, index),
          onEdit: () => addTags(context, index),
          onDelete: () {
            follows.removeAt(index);
            settings.follows.value = follows;
          },
          onType: () {
            switch (follows[index].type) {
              case FollowType.notify:
              case FollowType.update:
                follows[index].type = FollowType.bookmark;
                break;
              case FollowType.bookmark:
                follows[index].type = FollowType.update;
                break;
            }
            settings.follows.value = follows;
          },
        ),
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
            onPressed: Navigator.of(context).maybePop,
          ),
          TextButton(
            child: Text('OK'),
            onPressed: () {
              List<String> tags = controller.text.split('\n');
              tags = tags.trim();
              tags.removeWhere((tag) => tag.isEmpty);
              settings.follows.value = follows.editWith(tags);
              Navigator.of(context).maybePop();
            },
          ),
        ],
      );
    }

    return Scaffold(
      appBar: ScrollToTop(
        controller: scrollController,
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
      ),
      body: body(),
      floatingActionButton: Builder(
        builder: (context) => AnimatedBuilder(
          animation: sheetController,
          builder: (context, child) => FloatingActionButton(
            child: Icon(sheetController.isShown ? Icons.check : Icons.add),
            onPressed: sheetController.action ?? () => addTags(context),
          ),
        ),
      ),
    );
  }
}
