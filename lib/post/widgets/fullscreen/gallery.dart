import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class PostFullscreenGallery extends StatefulWidget {
  final int index;
  final List<Post> posts;
  final Function(int index)? onPageChanged;

  PostFullscreenGallery(
      {this.index = 0, required this.posts, this.onPageChanged});

  @override
  _PostFullscreenGalleryState createState() => _PostFullscreenGalleryState();
}

class _PostFullscreenGalleryState extends State<PostFullscreenGallery> {
  FrameController frameController = FrameController();
  late ValueNotifier<int> current = ValueNotifier(widget.index);

  @override
  void dispose() {
    frameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: current,
      builder: (context, int value, child) => PostFullscreenFrame(
        child: child!,
        post: widget.posts[value],
        controller: frameController,
      ),
      child: PageView.builder(
        itemCount: widget.posts.length,
        controller: PageController(initialPage: widget.index),
        itemBuilder: (context, int index) =>
            PostFullscreenImageDisplay(post: widget.posts[index]),
        onPageChanged: (index) {
          current.value = index;
          widget.onPageChanged!(index);
          preloadImages(
            context: context,
            index: index,
            posts: widget.posts,
            size: ImageSize.file,
          );
        },
      ),
    );
  }
}
