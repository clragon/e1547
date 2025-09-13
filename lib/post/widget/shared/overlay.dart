import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class PostImageOverlay extends StatelessWidget {
  const PostImageOverlay({
    super.key,
    required this.post,
    required this.builder,
  });

  final Post post;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    if (post.file == null) {
      if (post.isDeleted) {
        return const IconMessage(
          title: Text('Post was deleted'),
          icon: Icon(Icons.delete_outlined),
        );
      }

      return const IconMessage(
        title: Text('Post is unavailable'),
        icon: Icon(Icons.no_adult_content),
      );
    }

    PostFilter? filter = context.watch<PostFilter?>();
    if ((filter?.denies(post) ?? false) && !post.isFavorited) {
      return const IconMessage(
        title: Text('Post is blacklisted'),
        icon: Icon(Icons.block),
      );
    }

    if (post.type == PostType.unsupported) {
      return IconMessage(
        title: Text('${post.ext} files are not supported'),
        icon: const Icon(Icons.image_not_supported_outlined),
      );
    }

    return builder(context);
  }
}
