import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
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
  Map<ChangeNotifier, VoidCallback> get initLinks => {
        settings.denylist: updateDenylist,
      };

  void updateDenylist() =>
      setState(() => denylist = List.from(settings.denylist.value));

  void addTags(BuildContext context, [int? edit]) {
    Future<void> submit(String value, [int? edit]) async {
      value = value.trim();

      if (edit != null) {
        if (value.isNotEmpty) {
          denylist[edit] = value;
        } else {
          denylist.removeAt(edit);
        }
      } else if (value.isNotEmpty) {
        denylist.add(value);
      }
      if (!await updateBlacklist(context: context, denylist: denylist)) {
        throw ControllerException(message: 'Failed to update blacklist!');
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
        itemBuilder: (context, index) => DenylistTile(
            tag: denylist[index],
            onEdit: () => addTags(context, index),
            onDelete: () {
              denylist.removeAt(index);
              updateBlacklist(
                  context: context, denylist: denylist, immediate: true);
            }),
        physics: BouncingScrollPhysics(),
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
                builder: (context) => DenylistEditor(denylist: denylist),
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
