import 'package:e1547/tag/tag.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/material.dart';

class TopicsPageFloatingActionButton extends StatelessWidget {
  const TopicsPageFloatingActionButton({
    super.key,
    required this.controller,
  });

  final TopicsController controller;

  @override
  Widget build(BuildContext context) {
    return SearchPromptFloatingActionButton(
      tags: controller.query,
      onSubmit: (value) => controller.query = QueryMap(value),
      filters: [
        WrapperFilterConfig(
          wrapper: (value) => 'search[$value]',
          unwrapper: (value) => value.substring(7, value.length - 1),
          filters: [
            PrimaryFilterConfig(
              filter: const TextFilterTag(
                tag: 'title_matches',
                name: 'Name',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
