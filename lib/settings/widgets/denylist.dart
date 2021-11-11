import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DenyListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DenyListPageState();
  }
}

class _DenyListPageState extends State<DenyListPage> with LinkingMixin {
  List<String> denylist = [];
  SheetActionController sheetController = SheetActionController();
  RefreshController refreshController = RefreshController();

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
      ControlledTextWrapper(
        submit: (value) => submit(sortTags(value), edit),
        actionController: sheetController,
        textController:
            TextEditingController(text: edit != null ? denylist[edit] : null),
        builder: (context, controller, submit) => TagInput(
          controller: controller,
          labelText: 'Add to blacklist',
          submit: submit,
          readOnly: sheetController.isLoading,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshablePageLoader(
      onEmptyIcon: Icon(Icons.check),
      onEmpty: Text('Your blacklist is empty'),
      onLoading: Text('Loading blacklist'),
      onError: Text('Failed to load blacklist'),
      isError: false,
      isLoading: false,
      isBuilt: true,
      isEmpty: denylist.isEmpty,
      refreshController: refreshController,
      refreshHeader: RefreshablePageDefaultHeader(
        completeText: 'refreshed blacklist',
        refreshingText: 'refreshing blacklist',
      ),
      builder: (context) => ListView.builder(
        physics: BouncingScrollPhysics(),
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
          },
        ),
      ),
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
      floatingActionButton: Builder(
        builder: (context) => AnimatedBuilder(
          animation: sheetController,
          builder: (context, child) => FloatingActionButton(
            child: Icon(sheetController.isShown ? Icons.check : Icons.add),
            onPressed: sheetController.isLoading
                ? null
                : sheetController.action ?? () => addTags(context),
          ),
        ),
      ),
      refresh: () async {
        if (await validateCall(
            () => client.initializeCurrentUser(reset: true))) {
          refreshController.refreshCompleted();
        } else {
          refreshController.refreshFailed();
        }
      },
    );
  }
}
