import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PostFullscreenImage extends StatelessWidget {
  final Post post;

  const PostFullscreenImage(this.post);

  @override
  Widget build(BuildContext context) {
    return PhotoViewGestureDetectorScope(
      axis: Axis.horizontal,
      child: PhotoView.customChild(
        heroAttributes: PhotoViewHeroAttributes(tag: post.hero),
        backgroundDecoration: BoxDecoration(color: Colors.transparent),
        childSize:
            Size(post.file.width.toDouble(), post.file.height.toDouble()),
        child: PostImageWidget(post: post, size: ImageSize.file),
        initialScale: PhotoViewComputedScale.contained,
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 6,
      ),
    );
  }
}

class PostFullscreenImageDisplay extends StatelessWidget {
  final Post post;

  const PostFullscreenImageDisplay({required this.post});

  @override
  Widget build(BuildContext context) {
    return ImageOverlay(
      post: post,
      builder: (post) {
        switch (post.type) {
          case PostType.Image:
            return PostFullscreenImage(post);
          case PostType.Video:
            return Center(
              child: Hero(
                tag: post.hero,
                child: PostVideoLoader(
                  post: post,
                  child: VideoGestures(
                    child: PostVideoWidget(post: post),
                    videoController: post.controller!,
                  ),
                ),
              ),
            );
          case PostType.Unsupported:
          default:
            // this never occurs, it is caught by ImageOverlay
            return SizedBox.shrink();
        }
      },
    );
  }
}
