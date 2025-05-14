import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PostFullscreen extends StatelessWidget {
  const PostFullscreen({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return PostHistoryConnector(
      post: post,
      child: PostFullscreenFrame(
        post: post,
        child: PostVideoRoute(
          post: post,
          stopOnDispose: false,
          child: PostImageOverlay(
            post: post,
            builder: (context) {
              switch (post.type) {
                case PostType.image:
                  if (Theme.of(context).isDesktop) {
                    return InteractiveViewer(
                      maxScale: 6,
                      child: Center(
                        child: Hero(
                          tag: post.link,
                          child: PostImageWidget(
                            post: post,
                            fit: BoxFit.cover,
                            size: PostImageSize.file,
                            lowResCacheSize:
                                context.watch<ImageCacheSize?>()?.size,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return PhotoViewGestureDetectorScope(
                      axis: Axis.horizontal,
                      child: PhotoView.customChild(
                        heroAttributes: PhotoViewHeroAttributes(tag: post.link),
                        backgroundDecoration:
                            const BoxDecoration(color: Colors.transparent),
                        childSize:
                            Size(post.width.toDouble(), post.height.toDouble()),
                        initialScale: PhotoViewComputedScale.contained,
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered * 6,
                        child: PostImageWidget(
                          fit: BoxFit.cover,
                          post: post,
                          size: PostImageSize.file,
                          lowResCacheSize:
                              context.watch<ImageCacheSize?>()?.size,
                        ),
                      ),
                    );
                  }
                case PostType.video:
                  return Center(
                    child: Hero(
                      tag: post.link,
                      child: VideoGestures(
                        player: post.getVideo(context)!,
                        child: PostVideoWidget(post: post),
                      ),
                    ),
                  );
                case PostType.unsupported:
                  // this never occurs, ImageOverlay will display instead.
                  throw StateError(
                      'PostFullscreen received an unsupported image!');
              }
            },
          ),
        ),
      ),
    );
  }
}
