import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class PostTile extends StatelessWidget {
  final Post post;
  final VoidCallback? onPressed;

  PostTile({
    required this.post,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Widget overlay({required Widget child}) {
      if (post.flags.deleted) {
        return Center(child: Text('deleted'));
      }
      if (post.type == PostType.Unsupported) {
        return Center(child: Text('unsupported'));
      }
      if (post.file.url == null) {
        return Center(child: Text('unsafe'));
      }
      return child;
    }

    Widget tag() {
      if (post.file.ext == 'gif') {
        return Container(
          color: Colors.black12,
          child: Icon(Icons.gif),
        );
      }
      if (post.type == PostType.Video) {
        return Container(
          color: Colors.black12,
          child: Icon(Icons.play_arrow),
        );
      }
      return SizedBox.shrink();
    }

    Widget image() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: AnimatedBuilder(
                animation: post,
                builder: (context, value) {
                  return overlay(
                    child: Hero(
                      flightShuttleBuilder: imageFlightShuttleBuilder,
                      tag: post.hero,
                      child: PostImageWidget(
                        post: post,
                        size: ImageSize.sample,
                        fit: BoxFit.cover,
                        showProgress: false,
                        withPreview: false,
                      ),
                    ),
                  );
                }),
          ),
        ],
      );
    }

    return FakeCard(
      child: Stack(
        children: [
          image(),
          Positioned(top: 0, right: 0, child: tag()),
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onPressed,
            ),
          ),
        ],
      ),
    );
  }
}
