import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DenyListPage extends StatefulWidget {
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
      child: AnimatedBuilder(
        animation: denylistController,
        builder: (context, child) => RefreshablePageLoader(
          onEmptyIcon: const Icon(Icons.check),
          onEmpty: const Text('Your blacklist is empty'),
          onLoading: const Text('Loading blacklist'),
          onError: const Text('Failed to load blacklist'),
          isError: false,
          isLoading: false,
          isBuilt: true,
          isEmpty: denylistController.items.isEmpty,
          refreshController: refreshController,
          refreshHeader: const RefreshablePageDefaultHeader(
            completeText: 'refreshed blacklist',
            refreshingText: 'refreshing blacklist',
          ),
          builder: (context) => ListView.builder(
            padding: defaultActionListPadding
                .add(LimitedWidthLayout.of(context)!.padding),
            itemCount: denylistController.items.length,
            itemBuilder: (context, index) => DenylistTile(
              tag: denylistController.items[index],
              onEdit: () {
                String tag = denylistController.items[index];
                edit(
                  context: context,
                  title: 'Edit tag',
                  initial: tag,
                  submit: (value) async {
                    value = value.trim();
                    try {
                      if (value.isEmpty) {
                        await denylistController.remove(value);
                      } else {
                        await denylistController.replace(tag, value);
                      }
                    } on DioError {
                      throw const ActionControllerException(
                          message: 'Failed to update blacklist!');
                    }
                  },
                );
              },
              onDelete: () {
                denylistController.removeAt(index);
              },
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
                                    await denylistController.add(value);
                                  }
                                } on DioError {
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
            if (await validateCall(
                () => denylistController.update(force: true))) {
              refreshController.refreshCompleted();
            } else {
              refreshController.refreshFailed();
            }
          },
        ),
      ),
    );
  }
}
