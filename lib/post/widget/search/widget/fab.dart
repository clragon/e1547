import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class PostsPageFab extends StatelessWidget {
  const PostsPageFab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PostParams>();
    return SearchPromptFloatingActionButton(
      tags: controller.query,
      onSubmit: (value) => controller.query = value,
      filters: [
        PrimaryFilterConfig(
          filter: TagSearchFilterTag(tag: 'tags', name: 'Tags'),
          filters: [PostParams.tagsFilter],
        ),
      ],
    );
  }
}
