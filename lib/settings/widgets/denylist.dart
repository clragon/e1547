import 'package:e1547/interface.dart';
import 'package:e1547/settings.dart';
import 'package:e1547/tag.dart';
import 'package:e1547/wiki.dart';
import 'package:flutter/material.dart';

class DenyListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DenyListPageState();
  }
}

class _DenyListPageState extends State<DenyListPage> with LinkingMixin {
  List<String> denylist = [];
  SheetActionController sheetController = SheetActionController();

  @override
  Map<ChangeNotifier, VoidCallback> get links => {
        settings.denylist: updateDenylist,
      };

  Future<void> updateDenylist() async => settings.denylist.value.then(
        (value) {
          if (mounted) {
            setState(() => denylist = value);
          }
        },
      );

  void addTags(BuildContext context, [int? edit]) {
    void submit(String value, [int? edit]) {
      value = value.trim();

      if (edit != null) {
        if (value.isNotEmpty) {
          denylist[edit] = value;
        } else {
          denylist.removeAt(edit);
        }
        settings.denylist.value = Future.value(denylist);
      } else {
        if (value.isNotEmpty) {
          denylist.add(value);
          settings.denylist.value = Future.value(denylist);
        }
      }
    }

    sheetController.show(
      context,
      SheetTextWrapper(
        submit: (value) => submit(sortTags(value), edit),
        actionController: sheetController,
        textController:
            TextEditingController(text: edit != null ? denylist[edit] : null),
        builder: (context, controller, submit) => TagInput(
          controller: controller,
          labelText: 'Add to blacklist',
          submit: submit,
        ),
      ),
    );
  }

  Widget denyListTile({
    required String tag,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
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
                  children: Tagset.parse(tag)
                      .map((tag) => DenyListTagCard(tag.toString()))
                      .toList(),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  PopupMenuButton<VoidCallback?>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onSelected: (value) => value?.call(),
                    itemBuilder: (context) => [
                      PopupMenuTile(
                        value: onEdit,
                        title: 'Edit',
                        icon: Icons.edit,
                      ),
                      PopupMenuTile(
                        value: onDelete,
                        title: 'Delete',
                        icon: Icons.delete,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Divider()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body() {
      if (denylist.isEmpty) {
        return IconMessage(
          icon: Icon(Icons.check),
          title: Text('Your blacklist is empty'),
        );
      }

      return ListView.builder(
        padding:
            EdgeInsets.only(top: 8, bottom: kBottomNavigationBarHeight + 24),
        itemCount: denylist.length,
        itemBuilder: (context, index) => denyListTile(
            tag: denylist[index],
            onEdit: () => addTags(context, index),
            onDelete: () {
              denylist.removeAt(index);
              settings.denylist.value = Future.value(denylist);
            }),
        physics: BouncingScrollPhysics(),
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
            onPressed: Navigator.of(context).maybePop,
          ),
          TextButton(
            child: Text('OK'),
            onPressed: () {
              List<String> tags = controller.text.split('\n');
              tags = tags.map((e) => e.trim()).toList();
              tags.removeWhere((tag) => tag.isEmpty);
              settings.denylist.value = Future.value(tags);
              Navigator.of(context).maybePop();
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
            },
          ),
        ],
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
