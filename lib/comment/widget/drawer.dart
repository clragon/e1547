import 'package:e1547/comment/comment.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class CommentListDrawer extends StatelessWidget {
  const CommentListDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CommentFilter>();
    return ContextDrawer(
      title: const Text('Comments'),
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.sort),
          title: const Text('Comment order'),
          subtitle: Text(switch (controller.order) {
            CommentOrder.oldest => 'oldest first',
            CommentOrder.newest => 'newest first',
          }),
          value: controller.order == CommentOrder.oldest,
          onChanged: (value) {
            controller.order = value
                ? CommentOrder.oldest
                : CommentOrder.newest;
            Scaffold.of(context).closeEndDrawer();
          },
        ),
      ],
    );
  }
}
