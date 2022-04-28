import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class ImageOverlay extends StatelessWidget {
  final Post post;
  final PostController? controller;
  final WidgetBuilder builder;

  const ImageOverlay({
    required this.post,
    required this.builder,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([controller]),
      builder: (context, child) {
        Widget centerText(String text) {
          return Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
            ),
          );
        }

        if (post.flags.deleted) {
          return centerText('Post was deleted');
        }
        if (post.file.url == null) {
          return centerText('Image unavailable in safe mode');
        }
        if (controller != null &&
            controller!.isDenied(post) &&
            !post.isFavorited) {
          return centerText('Post is blacklisted');
        }

        if (post.type == PostType.unsupported) {
          return IconMessage(
            title: Text('${post.file.ext} files are not supported'),
            icon: const Icon(Icons.image_not_supported_outlined),
            action: Padding(
              padding: const EdgeInsets.all(4),
              child: TextButton(
                onPressed: () async => launch(post.file.url!),
                child: const Text('Open'),
              ),
            ),
          );
        }

        return builder(context);
      },
    );
  }
}
