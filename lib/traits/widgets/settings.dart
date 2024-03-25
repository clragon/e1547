import 'package:e1547/client/client.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/material.dart';

class DenyListPage extends StatefulWidget {
  const DenyListPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DenyListPageState();
  }
}

class _DenyListPageState extends State<DenyListPage> {
  final SheetActionController sheetController = SheetActionController();

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
          direction: VerticalDirection.up,
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
      child: Consumer<Client>(
        builder: (context, client, child) => ValueListenableBuilder(
          valueListenable: client.traits,
          builder: (context, traits, child) {
            List<String> denylist = traits.denylist.toList();
            return RefreshableLoadingPage(
              onEmpty: const IconMessage(
                icon: Icon(Icons.check),
                title: Text('Your blacklist is empty'),
              ),
              onError: const Text('Failed to load blacklist'),
              isError: false,
              isLoading: false,
              isBuilt: true,
              isEmpty: denylist.isEmpty,
              refreshHeader: const RefreshablePageDefaultHeader(
                completeText: 'refreshed blacklist',
                refreshingText: 'refreshing blacklist',
              ),
              child: (context) => ListView.builder(
                primary: true,
                padding: defaultActionListPadding
                    .add(LimitedWidthLayout.of(context).padding),
                itemCount: denylist.length,
                itemBuilder: (context, index) => DenylistTile(
                  tag: denylist[index],
                  onEdit: () {
                    String tag = denylist[index];
                    edit(
                      context: context,
                      title: 'Edit tag',
                      initial: tag,
                      submit: (value) async {
                        value = value.trim();
                        try {
                          if (value.isEmpty) {
                            await client.bridge.push(
                              traits: traits.copyWith(
                                denylist: denylist..remove(tag),
                              ),
                            );
                          } else {
                            await client.bridge.push(
                              traits: traits.copyWith(
                                denylist: denylist
                                  ..[denylist.indexOf(tag)] = value,
                              ),
                            );
                          }
                        } on ClientException {
                          throw const ActionControllerException(
                            message: 'Failed to update blacklist!',
                          );
                        }
                      },
                    );
                  },
                  onDelete: () => client.bridge.push(
                    traits: traits.copyWith(
                      denylist: denylist..remove(denylist[index]),
                    ),
                  ),
                ),
              ),
              appBar: DefaultAppBar(
                title: const Text('Blacklist'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const DenyListEditor(),
                      ),
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
                                        await client.bridge.push(
                                          traits: traits.copyWith(
                                            denylist: denylist..add(value),
                                          ),
                                        );
                                      }
                                    } on ClientException {
                                      throw const ActionControllerException(
                                        message: 'Failed to update blacklist!',
                                      );
                                    }
                                  },
                                ),
                    child:
                        Icon(sheetController.isShown ? Icons.check : Icons.add),
                  ),
                ),
              ),
              refresh: (refreshController) async {
                try {
                  await client.bridge.pull(force: true);
                  refreshController.refreshCompleted();
                } on ClientException {
                  refreshController.refreshFailed();
                }
              },
            );
          },
        ),
      ),
    );
  }
}
