import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:flutter/material.dart';

class PostPhotoGallery extends StatefulWidget {
  final int index;
  final List<Post> posts;
  final Function(int index)? onPageChanged;

  PostPhotoGallery({this.index = 0, required this.posts, this.onPageChanged});

  @override
  _PostPhotoGalleryState createState() => _PostPhotoGalleryState();
}

class _PostPhotoGalleryState extends State<PostPhotoGallery> {
  ValueNotifier<bool> showFrame = ValueNotifier(false);
  late ValueNotifier<int> current = ValueNotifier(widget.index);

  void toggleFrame({bool? shown}) {
    showFrame.value = shown ?? !showFrame.value;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: current,
      builder: (context, int value, child) => Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: ValueListenableBuilder(
            valueListenable: showFrame,
            child: PostPhotoAppBar(post: widget.posts[value]),
            builder: (context, bool visible, child) => CrossFade(
              showChild: visible,
              child: child!,
            ),
          ),
        ),
        body: VideoFrame(
          child: child!,
          post: widget.posts[value],
          onToggle: (shown) => toggleFrame(shown: shown),
        ),
      ),
      child: PageView.builder(
        itemCount: widget.posts.length,
        controller: PageController(initialPage: widget.index),
        physics: BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) => ImageOverlay(
          post: widget.posts[index],
          builder: (post) {
            switch (widget.posts[index].type) {
              case PostType.Image:
                return PostPhoto(post);
              case PostType.Video:
                return Hero(
                  tag: widget.posts[index].hero,
                  child: PostVideoLoader(
                      post: post, child: PostVideoWidget(post: post)),
                );
              case PostType.Unsupported:
              default:
                // this never occurs, it is caught by ImageOverlay
                return SizedBox.shrink();
            }
          },
        ),
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
