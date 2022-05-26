import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PostFullscreen extends StatelessWidget {
  final Post post;
  final PostController? controller;

  const PostFullscreen({required this.post, this.controller});

  @override
  Widget build(BuildContext context) {
    return ImageOverlay(
      post: post,
      controller: controller,
      builder: (context) {
        switch (post.type) {
          case PostType.image:
            return PhotoViewGestureDetectorScope(
              axis: Axis.horizontal,
              child: PhotoView.customChild(
                heroAttributes: PhotoViewHeroAttributes(tag: post.hero),
                backgroundDecoration:
                    const BoxDecoration(color: Colors.transparent),
                childSize: Size(
                    post.file.width.toDouble(), post.file.height.toDouble()),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 6,
                child: PostImageWidget(post: post, size: ImageSize.file),
              ),
            );
          case PostType.video:
            return Center(
              child: Hero(
                tag: post.hero,
                child: PostVideoLoader(
                  post: post,
                  child: VideoGestures(
                    videoController: post.getVideo(context)!,
                    child: PostVideoWidget(post: post),
                  ),
                ),
              ),
            );
          case PostType.unsupported:
            // this never occurs, ImageOverlay will display instead.
            throw StateError('PostFullscreen received an unsupported image!');
        }
      },
    );
  }
}
