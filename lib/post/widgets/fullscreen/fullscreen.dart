import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PostFullscreen extends StatelessWidget {
  final PostController post;

  const PostFullscreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return PostFullscreenFrame(
      post: post.value,
      child: PostFullscreenBody(
        post: post,
      ),
    );
  }
}

class PostFullscreenBody extends StatelessWidget {
  final PostController post;

  const PostFullscreenBody({required this.post});

  @override
  Widget build(BuildContext context) {
    return PostVideoRoute(
      post: post.value,
      stopOnDispose: false,
      child: ImageOverlay(
        post: post,
        builder: (context) {
          switch (post.value.type) {
            case PostType.image:
              return PhotoViewGestureDetectorScope(
                axis: Axis.horizontal,
                child: PhotoView.customChild(
                  heroAttributes: PhotoViewHeroAttributes(tag: post.value.link),
                  backgroundDecoration:
                      const BoxDecoration(color: Colors.transparent),
                  childSize: Size(post.value.file.width.toDouble(),
                      post.value.file.height.toDouble()),
                  initialScale: PhotoViewComputedScale.contained,
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 6,
                  child:
                      PostImageWidget(post: post.value, size: ImageSize.file),
                ),
              );
            case PostType.video:
              return Center(
                child: Hero(
                  tag: post.value.link,
                  child: PostVideoLoader(
                    post: post.value,
                    child: VideoGestures(
                      videoController: post.value.getVideo(context)!,
                      child: PostVideoWidget(post: post.value),
                    ),
                  ),
                ),
              );
            case PostType.unsupported:
              // this never occurs, ImageOverlay will display instead.
              throw StateError('PostFullscreen received an unsupported image!');
          }
        },
      ),
    );
  }
}
