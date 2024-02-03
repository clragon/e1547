import 'package:e1547/app/app.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
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
    PostsController? controller = context.read<PostsController?>();

    Widget centerText(String text) {
      return Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      );
    }

    if (post.isDeleted) {
      return centerText('Post was deleted');
    }
    if (post.file == null) {
      return const IconMessage(
        title: Text('Image unavailable on this host'),
        icon: Icon(Icons.image_not_supported_outlined),
      );
    }
    if ((controller?.isDenied(post) ?? false) && !post.isFavorited) {
      return centerText('Post is blacklisted');
    }

    if (post.type == PostType.unsupported) {
      return IconMessage(
        title: Text('${post.ext} files are not supported'),
        icon: const Icon(Icons.image_not_supported_outlined),
        action: Padding(
          padding: const EdgeInsets.all(4),
          child: TextButton(
            onPressed: () async => launch(post.file!),
            child: const Text('Open'),
          ),
        ),
      );
    }

    return builder(context);
  }
}
