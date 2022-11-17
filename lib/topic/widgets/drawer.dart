import 'package:e1547/topic/topic.dart';
import 'package:flutter/material.dart';

class TopicTagEditingTile extends StatelessWidget {
  const TopicTagEditingTile({super.key, required this.controller});

  final TopicsController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.hideTagEditing,
      builder: (context, value, child) => SwitchListTile(
        secondary: const Icon(Icons.inventory_outlined),
        title: const Text('hide tags edits'),
        subtitle: Text(
          value
              ? 'hide tag alias and implications'
              : 'show tag alias and implications',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        value: value,
        onChanged: (value) => controller.hideTagEditing.value = value,
      ),
    );
  }
}
