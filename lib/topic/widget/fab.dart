import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/material.dart';

class TopicSearchFab extends StatelessWidget {
  const TopicSearchFab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TopicParams>();
    return SearchPromptFloatingActionButton(
      tags: controller.query,
      onSubmit: (value) => controller.query = value,
      filters: [
        PrimaryFilterConfig(
          filter: TopicParams.titleFilter,
          filters: [
            TopicParams.categoryIdFilter,
            TopicParams.orderFilter,
            TopicParams.stickyFilter,
            TopicParams.lockedFilter,
          ],
        ),
      ],
    );
  }
}
