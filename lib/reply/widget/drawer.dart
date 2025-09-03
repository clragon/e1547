import 'package:e1547/reply/reply.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class ReplyListDrawer extends StatelessWidget {
  const ReplyListDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ReplyParams>();
    return ContextDrawer(
      title: const Text('Replies'),
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.sort),
          title: const Text('Reply order'),
          subtitle: Text(switch (controller.order) {
            ReplyOrder.oldest => 'oldest first',
            ReplyOrder.newest => 'newest first',
          }),
          value: controller.order == ReplyOrder.oldest,
          onChanged: (value) {
            controller.order = value ? ReplyOrder.oldest : ReplyOrder.newest;
            Scaffold.of(context).closeEndDrawer();
          },
        ),
      ],
    );
  }
}
