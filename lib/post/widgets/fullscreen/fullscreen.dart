import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PostFullscreen extends StatelessWidget {
  const PostFullscreen({
    super.key,
    required this.controller,
    this.showFrame,
  });

  final PostController controller;
  final bool? showFrame;

  @override
  Widget build(BuildContext context) {
    return PostFullscreenFrame(
      post: controller.value,
      visible: showFrame,
      child: PostFullscreenBody(
        controller: controller,
      ),
    );
  }
}

class PostFullscreenBody extends StatelessWidget {
  const PostFullscreenBody({required this.controller});

  final PostController controller;

  @override
  Widget build(BuildContext context) {
    return PostVideoRoute(
      post: controller.value,
      stopOnDispose: false,
      child: ImageOverlay(
        controller: controller,
        builder: (context) {
          switch (controller.value.type) {
            case PostType.image:
              return PhotoViewGestureDetectorScope(
                axis: Axis.horizontal,
                child: PhotoView.customChild(
                  heroAttributes:
                      PhotoViewHeroAttributes(tag: controller.value.link),
                  backgroundDecoration:
                      const BoxDecoration(color: Colors.transparent),
                  childSize: Size(controller.value.file.width.toDouble(),
                      controller.value.file.height.toDouble()),
                  initialScale: PhotoViewComputedScale.contained,
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 6,
                  child: PostImageWidget(
                    fit: BoxFit.cover,
                    post: controller.value,
                    size: PostImageSize.file,
                    lowResCacheSize: context.read<LowResCacheSize?>()?.size,
                  ),
                ),
              );
            case PostType.video:
              return Center(
                child: Hero(
                  tag: controller.value.link,
                  child: PostVideoLoader(
                    post: controller.value,
                    child: VideoGestures(
                      videoController: controller.value.getVideo(context)!,
                      child: PostVideoWidget(post: controller.value),
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
