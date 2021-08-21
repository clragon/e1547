import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ImageOverlay extends StatelessWidget {
  final Post post;
  final Widget Function(Post post) builder;

  ImageOverlay({required this.post, required this.builder});

  @override
  Widget build(BuildContext context) {
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
    if (!post.isVisible) {
      return centerText('Post is blacklisted');
    }

    if (post.type == PostType.Unsupported) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  '${post.file.ext} files are not supported',
                  textAlign: TextAlign.center,
                ),
              ),
              Card(
                child: InkWell(
                  child:
                      Padding(padding: EdgeInsets.all(8), child: Text('Open')),
                  onTap: () async => launch(post.file.url!),
                ),
              )
            ],
          )
        ],
      );
    }
    return builder(post);
  }
}
