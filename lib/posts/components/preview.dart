import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/posts/post.dart';
import 'package:flutter/material.dart';

class PostPreview extends StatelessWidget {
  final Post post;
  final VoidCallback onPressed;

  PostPreview({
    @required this.post,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Widget imagePreviewWidget() {
      return ValueListenableBuilder(
          valueListenable: post.image,
          builder: (context, value, child) {
            if (post.image.value.file['url'] != null) {
              return Hero(
                tag: 'image_${post.id}',
                child: CachedNetworkImage(
                  imageUrl: post.image.value.sample['url'],
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.cover,
                ),
              );
            } else {
              return Center(child: Text(post.isDeleted ? 'deleted' : 'unsafe'));
            }
          });
    }

    Widget imageContainer() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: imagePreviewWidget(),
          ),
          // postInfoWidget(),
        ],
      );
    }

    Widget playOverlay() {
      if (post.image.value.file['ext'] == 'gif') {
        return Positioned(
            top: 0,
            right: 0,
            child: Container(
              color: Colors.black12,
              child: Icon(Icons.gif),
            ));
      }
      if (post.image.value.file['ext'] == 'webm') {
        return Positioned(
            top: 0,
            right: 0,
            child: Container(
              color: Colors.black12,
              child: Icon(Icons.play_arrow),
            ));
      }
      return Container();
    }

    return Card(
      child: InkWell(
          onTap: onPressed,
          child: () {
            return Stack(
              children: <Widget>[
                imageContainer(),
                playOverlay(),
              ],
            );
          }()),
    );
  }
}
