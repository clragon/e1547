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
                return IconMessage(
                  icon: Icon(Icons.bookmark),
                  title: Text('You are not following any tags'),
                );
              }

              return ListView.builder(
                padding: defaultActionListPadding
                    .add(LimitedWidthLayout.of(context)!.padding),
                physics: BouncingScrollPhysics(),
                itemCount: followController.items.length,
                itemBuilder: (context, index) => FollowListTile(
                  follow: followController.items[index],
                ),
              );
            }

            return Scaffold(
              appBar: DefaultAppBar(
                title: Text('Following'),
                actions: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () async => showDialog(
                      context: context,
                      builder: (context) => FollowEditor(),
                    ),
                  ),
                ],
              ),
              body: body(),
              floatingActionButton: Builder(
                builder: (context) => AnimatedBuilder(
                  animation: SheetActions.of(context)!,
                  builder: (context, child) => FloatingActionButton(
                    child: Icon(SheetActions.of(context)!.isShown
                        ? Icons.check
                        : Icons.add),
                    onPressed: SheetActions.of(context)!.action ?? addTags,
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
  const FollowEditor({Key? key}) : super(key: key);

  @override
  State<FollowEditor> createState() => _FollowEditorState();
}

class _FollowEditorState extends State<FollowEditor> {
  TextEditingController controller =
      TextEditingController(text: followController.items.tags.join('\n'));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Following'),
      content: TextField(
        scrollPhysics: BouncingScrollPhysics(),
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
