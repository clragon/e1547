import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class FollowingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  @override
  Widget build(BuildContext context) {
    return LimitedWidthLayout(
      child: SheetActions(
        controller: SheetActionController(),
        child: AnimatedBuilder(
          animation: followController,
          builder: (context, child) {
            void addTags() {
              SheetActions.of(context)!.show(
                context,
                ControlledTextWrapper(
                  submit: (value) async {
                    value = value.trim();
                    Follow result = Follow.fromString(value);
                    if (value.isNotEmpty) {
                      followController.add(result);
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
            }

            Widget body() {
              if (followController.items.isEmpty) {
                return const IconMessage(
                  icon: Icon(Icons.bookmark),
                  title: Text('You are not following any tags'),
                );
              }

              return ListView.builder(
                padding: defaultActionListPadding
                    .add(LimitedWidthLayout.of(context)!.padding),
                physics: const BouncingScrollPhysics(),
                itemCount: followController.items.length,
                itemBuilder: (context, index) => FollowListTile(
                  follow: followController.items[index],
                ),
              );
            }

            return Scaffold(
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
              body: body(),
              floatingActionButton: Builder(
                builder: (context) => AnimatedBuilder(
                  animation: SheetActions.of(context)!,
                  builder: (context, child) => FloatingActionButton(
                    onPressed: SheetActions.of(context)!.action ?? addTags,
                    child: Icon(SheetActions.of(context)!.isShown
                        ? Icons.check
                        : Icons.add),
                  ),
                ),
              ),
            );
          },
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
  TextEditingController controller =
      TextEditingController(text: followController.items.tags.join('\n'));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Following'),
      content: TextField(
        scrollPhysics: const BouncingScrollPhysics(),
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
            followController.edit(tags);
            Navigator.of(context).maybePop();
          },
        ),
      ],
    );
  }
}
