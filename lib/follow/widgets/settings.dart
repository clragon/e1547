import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class FollowingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _FollowingPageState();
  }
}

class _FollowingPageState extends State<FollowingPage> {
  SheetActionController sheetController = SheetActionController();

  @override
  Widget build(BuildContext context) {
    return LimitedWidthLayout(
      child: AnimatedBuilder(
        animation: followController,
        builder: (context, child) {
          void addTags(BuildContext context, {Follow? follow}) {
            sheetController.show(
              context,
              ControlledTextWrapper(
                submit: (value) async {
                  value = value.trim();
                  Follow result = Follow.fromString(value);
                  if (follow != null) {
                    if (value.isNotEmpty) {
                      followController.replace(
                          followController.items.indexOf(follow), result);
                    } else {
                      followController.remove(follow);
                    }
                  } else if (value.isNotEmpty) {
                    followController.add(result);
                  }
                },
                actionController: sheetController,
                textController: TextEditingController(text: follow?.tags),
                builder: (context, controller, submit) => TagInput(
                  controller: controller,
                  textInputAction: TextInputAction.done,
                  labelText: follow != null ? 'Edit follow' : 'Add to follows',
                  submit: submit,
                ),
              ),
            );
          }

          void editAlias(BuildContext context, Follow follow) {
            sheetController.show(
              context,
              ControlledTextField(
                labelText: 'Follow alias',
                actionController: sheetController,
                textController: TextEditingController(text: follow.name),
                submit: (value) {
                  String? alias = value.trim();
                  if (follow.alias != value) {
                    if (value.isNotEmpty) {
                      alias = value;
                    } else {
                      alias = null;
                    }
                    followController.replace(
                      followController.items.indexOf(follow),
                      Follow(
                        tags: follow.tags,
                        alias: alias,
                        type: follow.type,
                        statuses: follow.statuses,
                      ),
                    );
                  }
                },
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
                onRename: () =>
                    editAlias(context, followController.items[index]),
                onEdit: () =>
                    addTags(context, follow: followController.items[index]),
                onDelete: () =>
                    followController.remove(followController.items[index]),
                onChangeNotify: (enabled) => followController.replace(
                  index,
                  followController.items[index].copyWith(
                    type: enabled ? FollowType.notify : FollowType.update,
                  ),
                ),
                onChangeBookmark: (enabled) => followController.replace(
                  index,
                  followController.items[index].copyWith(
                    type: enabled ? FollowType.bookmark : FollowType.update,
                  ),
                ),
              ),
            );
          }

          Widget editor() {
            TextEditingController controller = TextEditingController(
                text: followController.items.tags.join('\n'));
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Following'),
                ],
              ),
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

          return Scaffold(
            appBar: DefaultAppBar(
              title: Text('Following'),
              actions: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () async => showDialog(
                    context: context,
                    builder: (context) => editor(),
                  ),
                ),
              ],
            ),
            body: body(),
            floatingActionButton: Builder(
              builder: (context) => AnimatedBuilder(
                animation: sheetController,
                builder: (context, child) => FloatingActionButton(
                  child:
                      Icon(sheetController.isShown ? Icons.check : Icons.add),
                  onPressed: sheetController.action ?? () => addTags(context),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
