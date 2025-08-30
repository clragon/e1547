import 'package:e1547/shared/shared.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/material.dart';

class TopicListDrawer extends StatelessWidget {
  const TopicListDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TopicFilter>();
    return ContextDrawer(
      title: const Text('Topics'),
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.sell),
          title: const Text('Hide tags edits'),
          subtitle: Text(
            controller.value.hideTagEditing ? 'hidden' : 'visible',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          value: controller.value.hideTagEditing,
          onChanged: (value) {
            controller.value = (hideTagEditing: value);
            Scaffold.of(context).closeEndDrawer();
          },
        ),
      ],
    );
  }
}
