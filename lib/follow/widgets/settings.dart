import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FollowingPage extends StatefulWidget {
  const FollowingPage();

  @override
  State<StatefulWidget> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  @override
  Widget build(BuildContext context) {
    return LimitedWidthLayout(
      child: SheetActions(
        controller: SheetActionController(),
        child: Consumer<FollowsService>(
          builder: (context, follows, child) => Scaffold(
            appBar: DefaultAppBar(
              title: const Text('Following'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async => showDialog(
                    context: context,
                    builder: (context) => const FollowEditor(),
                  ),
                ),
              ],
            ),
            body: follows.items.isNotEmpty
                ? ListView.builder(
                    padding: defaultActionListPadding
                        .add(LimitedWidthLayout.of(context).padding),
                    itemCount: follows.items.length,
                    itemBuilder: (context, index) => FollowListTile(
                      follow: follows.items[index],
                    ),
                  )
                : const IconMessage(
                    icon: Icon(Icons.bookmark),
                    title: Text('You are not following any tags'),
                  ),
            floatingActionButton: Builder(
              builder: (context) => AnimatedBuilder(
                animation: SheetActions.of(context)!,
                builder: (context, child) => FloatingActionButton(
                  onPressed: SheetActions.of(context)!.action ??
                      () {
                        SheetActions.of(context)!.show(
                          context,
                          ControlledTextWrapper(
                            submit: (value) async {
                              value = value.trim();
                              Follow result = Follow(tags: value);
                              if (value.isNotEmpty) {
                                follows.add(result);
                              }
                            },
                            actionController: SheetActions.of(context)!,
                            builder: (context, controller, submit) => TagInput(
                              controller: controller,
                              textInputAction: TextInputAction.done,
                              labelText: 'Add to follows',
                              submit: submit,
                            ),
                          ),
                        );
                      },
                  child: Icon(SheetActions.of(context)!.isShown
                      ? Icons.check
                      : Icons.add),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FollowEditor extends StatefulWidget {
  const FollowEditor();

  @override
  State<FollowEditor> createState() => _FollowEditorState();
}

class _FollowEditorState extends State<FollowEditor> {
  late TextEditingController controller = TextEditingController(
      text: context.read<FollowsService>().items.tags.join('\n'));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Following'),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.multiline,
        maxLines: null,
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).maybePop,
          child: const Text('CANCEL'),
        ),
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            List<String> tags = controller.text.split('\n');
            tags = tags.trim();
            tags.removeWhere((tag) => tag.isEmpty);
            context.read<FollowsService>().edit(tags);
            Navigator.of(context).maybePop();
          },
        ),
      ],
    );
  }
}
