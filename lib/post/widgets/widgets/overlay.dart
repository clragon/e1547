import 'package:e1547/app/app.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class ImageOverlay extends StatelessWidget {
  final PostController post;
  final WidgetBuilder builder;

  const ImageOverlay({
    required this.post,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([post]),
      builder: (context, child) {
        Widget centerText(String text) {
          return Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
            ),
          );
        }

        if (post.value.flags.deleted) {
          return centerText('Post was deleted');
        }
        if (post.value.file.url == null) {
          return centerText('Image unavailable in safe mode');
        }
        if (post.isDenied && !post.value.isFavorited) {
          return centerText('Post is blacklisted');
        }

        if (post.value.type == PostType.unsupported) {
          return IconMessage(
            title: Text('${post.value.file.ext} files are not supported'),
            icon: const Icon(Icons.image_not_supported_outlined),
            action: Padding(
              padding: const EdgeInsets.all(4),
              child: TextButton(
                onPressed: () async => launch(post.value.file.url!),
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
