import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/post.dart';
import 'package:flutter/material.dart';

class PostTile extends StatelessWidget {
  final Post post;
  final VoidCallback onPressed;

  PostTile({
    @required this.post,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Widget image() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ValueListenableBuilder(
                valueListenable: post.sample,
                builder: (context, value, child) {
                  if (post.isDeleted) {
                    return Center(child: Text('deleted'));
                  }
                  if (post.type == ImageType.Unsupported) {
                    return Center(child: Text('unsupported'));
                  }
                  if (post.file.value.url == null) {
                    return Center(child: Text('unsafe'));
                  }
                  return Hero(
                    tag: getPostHero(post),
                    child: CachedNetworkImage(
                      imageUrl: post.sample.value.url,
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      fit: BoxFit.cover,
                    ),
                  );
                }),
          ),
        ],
      );
    }

    Widget overlay() {
      if (post.file.value.ext == 'gif') {
        return Container(
          color: Colors.black12,
          child: Icon(Icons.gif),
        );
      }
      if (post.type == ImageType.Video) {
        return Container(
          color: Colors.black12,
          child: Icon(Icons.play_arrow),
        );
      }
      return SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        child: Stack(
          children: [
            image(),
            Positioned(top: 0, right: 0, child: overlay()),
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: onPressed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
