import 'package:e1547/topic/topic.dart';
import 'package:flutter/material.dart';

class TopicTagEditingTile extends StatelessWidget {
  const TopicTagEditingTile({super.key, required this.controller});

  final TopicsController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) => SwitchListTile(
        secondary: const Icon(Icons.inventory_outlined),
        title: const Text('hide tags edits'),
        subtitle: Text(
          controller.hideTagEditing
              ? 'hide tag alias and implications'
              : 'show tag alias and implications',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        value: controller.hideTagEditing,
        onChanged: (value) => controller.hideTagEditing = value,
      ),
    );
  }
}
