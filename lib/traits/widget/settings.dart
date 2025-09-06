import 'package:e1547/domain/domain.dart';
import 'package:e1547/query/query.dart';
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

    final domain = context.watch<Domain>();

    return PromptActions(
      child: LimitedWidthLayout(
        child: ValueListenableBuilder(
          valueListenable: domain.traits,
          builder: (context, traits, child) {
            final denylist = traits.denylist.toList();
            return AdaptiveScaffold(
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
              body: PullToRefresh(
                onRefresh: () => domain.accounts.pull(force: true),
                child: denylist.isEmpty
                    ? const Center(
                        child: IconMessage(
                          icon: Icon(Icons.check),
                          title: Text('Your blacklist is empty'),
                        ),
                      )
                    : ListView.builder(
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
                                      await domain.accounts.push(
                                        traits: traits.copyWith(
                                          denylist: List.of(denylist)
                                            ..remove(tag),
                                        ),
                                      );
                                    } else {
                                      await domain.accounts.push(
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
                          onDelete: () => domain.accounts.push(
                            traits: traits.copyWith(
                              denylist: denylist..remove(denylist[index]),
                            ),
                          ),
                        ),
                      ),
              ),
              floatingActionButton: PromptFloatingActionButton(
                builder: (context) => buildEditTextField(
                  context,
                  title: 'Add tag',
                  submit: (value) async {
                    value = value.trim();
                    if (value.isEmpty) return;
                    try {
                      await domain.accounts.push(
                        traits: traits.copyWith(denylist: denylist..add(value)),
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
            );
          },
        ),
      ),
    );
  }
}
