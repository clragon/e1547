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
        Builder(
          builder: (context) => SwitchListTile(
            secondary: const Icon(Icons.sort),
            title: const Text('Comment order'),
            subtitle: Text(switch (controller.order) {
              CommentOrder.id_asc => 'oldest first',
              CommentOrder.id_desc => 'newest first',
            }),
            value: controller.order == CommentOrder.id_asc,
            onChanged: (value) {
              controller.order = value
                  ? CommentOrder.id_asc
                  : CommentOrder.id_desc;
              Scaffold.of(context).closeEndDrawer();
            },
          ),
        ),
      ],
    );
  }
}
