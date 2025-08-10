import 'package:e1547/client/client.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/material.dart';

class DenyListPage extends StatelessWidget {
  const DenyListPage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget buildEditTextField(
      BuildContext context, {
      required String title,
      required SubmitString submit,
      String? value,
    }) => Material(
      child: ControlledTextWrapper(
        textController: TextEditingController(text: value),
        submit: submit,
        builder: (context, controller, submit) => TagInput(
          controller: controller,
          decoration: const InputDecoration(suffix: PromptTextFieldSuffix()),
          textInputAction: TextInputAction.done,
          direction: VerticalDirection.up,
          labelText: title,
          submit: submit,
          readOnly: PromptActions.of(context).isLoading,
        ),
      ),
    );

    return PromptActions(
      child: LimitedWidthLayout(
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
                onError: const IconMessage(
                  icon: Icon(Icons.warning_amber),
                  title: Text('Failed to load blacklist'),
                ),
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
                  padding: defaultActionListPadding.add(
                    LimitedWidthLayout.of(context).padding,
                  ),
                  itemCount: denylist.length,
                  itemBuilder: (context, index) => DenylistTile(
                    tag: denylist[index],
                    onEdit: () {
                      String tag = denylist[index];
                      PromptActions.of(context).show(
                        context,
                        buildEditTextField(
                          context,
                          value: tag,
                          title: 'Edit tag',
                          submit: (value) async {
                            value = value.trim();
                            try {
                              if (value.isEmpty) {
                                await client.accounts.push(
                                  traits: traits.copyWith(
                                    denylist: List.of(denylist)..remove(tag),
                                  ),
                                );
                              } else {
                                await client.accounts.push(
                                  traits: traits.copyWith(
                                    denylist: List.of(denylist)
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
                        ),
                      );
                    },
                    onDelete: () => client.accounts.push(
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
                floatingActionButton: PromptFloatingActionButton(
                  builder: (context) => buildEditTextField(
                    context,
                    title: 'Add tag',
                    submit: (value) async {
                      value = value.trim();
                      if (value.isEmpty) return;
                      try {
                        await client.accounts.push(
                          traits: traits.copyWith(
                            denylist: denylist..add(value),
                          ),
                        );
                      } on ClientException {
                        throw const ActionControllerException(
                          message: 'Failed to update blacklist!',
                        );
                      }
                    },
                  ),
                  icon: const Icon(Icons.add),
                ),
                refresh: (refreshController) async {
                  try {
                    await client.accounts.pull(force: true);
                    refreshController.refreshCompleted();
                  } on ClientException {
                    refreshController.refreshFailed();
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
