import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DenyListPage extends StatefulWidget {
  const DenyListPage();

  @override
  State<StatefulWidget> createState() {
    return _DenyListPageState();
  }
}

class _DenyListPageState extends State<DenyListPage> {
  final SheetActionController sheetController = SheetActionController();
  final RefreshController refreshController = RefreshController();

  void edit({
    required BuildContext context,
    required String title,
    required void Function(String value) submit,
    String? initial,
  }) {
    sheetController.show(
      context,
      ControlledTextWrapper(
        submit: submit,
        actionController: sheetController,
        textController: TextEditingController(text: initial),
        builder: (context, controller, submit) => TagInput(
          controller: controller,
          textInputAction: TextInputAction.done,
          labelText: title,
          submit: submit,
          readOnly: sheetController.isLoading,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LimitedWidthLayout(
      child: Consumer<DenylistService>(
        builder: (context, denylist, child) => RefreshableLoadingPage(
          onEmptyIcon: const Icon(Icons.check),
          onEmpty: const Text('Your blacklist is empty'),
          onError: const Text('Failed to load blacklist'),
          isError: false,
          isLoading: false,
          isBuilt: true,
          isEmpty: denylist.items.isEmpty,
          refreshController: refreshController,
          refreshHeader: const RefreshablePageDefaultHeader(
            completeText: 'refreshed blacklist',
            refreshingText: 'refreshing blacklist',
          ),
          child: (context) => ListView.builder(
            primary: true,
            padding: defaultActionListPadding
                .add(LimitedWidthLayout.of(context).padding),
            itemCount: denylist.items.length,
            itemBuilder: (context, index) => DenylistTile(
              tag: denylist.items[index],
              onEdit: () {
                String tag = denylist.items[index];
                edit(
                  context: context,
                  title: 'Edit tag',
                  initial: tag,
                  submit: (value) async {
                    value = value.trim();
                    try {
                      if (value.isEmpty) {
                        await denylist.remove(value);
                      } else {
                        await denylist.replace(tag, value);
                      }
                    } on ClientException {
                      throw const ActionControllerException(
                          message: 'Failed to update blacklist!');
                    }
                  },
                );
              },
              onDelete: () => denylist.removeAt(index),
            ),
          ),
          appBar: DefaultAppBar(
            title: const Text('Blacklist'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => const DenyListEditor(),
                ),
              ),
            ],
          ),
          floatingActionButton: Builder(
            builder: (context) => AnimatedBuilder(
              animation: sheetController,
              builder: (context, child) => FloatingActionButton(
                onPressed: sheetController.isLoading
                    ? null
                    : sheetController.action ??
                        () => edit(
                              context: context,
                              title: 'Add tag',
                              submit: (value) async {
                                value = value.trim();
                                try {
                                  if (value.isNotEmpty) {
                                    await denylist.add(value);
                                  }
                                } on ClientException {
                                  throw const ActionControllerException(
                                      message: 'Failed to update blacklist!');
                                }
                              },
                            ),
                child: Icon(sheetController.isShown ? Icons.check : Icons.add),
              ),
            ),
          ),
          refresh: () async {
            try {
              await denylist.pull();
              refreshController.refreshCompleted();
            } on DenylistUpdateException {
              refreshController.refreshFailed();
            }
          },
        ),
      ),
    );
  }
}
