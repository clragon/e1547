import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class PostDetailGallery extends StatefulWidget {
  final PostController controller;
  final int initialPage;

  const PostDetailGallery({required this.controller, this.initialPage = 0});

  @override
  _PostDetailGalleryState createState() => _PostDetailGalleryState();
}

class _PostDetailGalleryState extends State<PostDetailGallery> {
  late int lastIndex = widget.initialPage;
  late PageController pageController =
      PageController(initialPage: widget.initialPage);

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      itemBuilder: (context, index) => PostDetail(
        post: widget.controller.itemList![index],
        controller: widget.controller,
        onPageChanged: (index) => ModalRoute.of(context)!.isCurrent
            ? pageController.animateToPage(index,
                duration: defaultAnimationDuration, curve: Curves.easeInOut)
            : pageController.jumpToPage(index),
      ),
      itemCount: widget.controller.itemList?.length ?? 0,
      onPageChanged: (index) {
        if (widget.controller.itemList!.isNotEmpty) {
          Post lastPost = widget.controller.itemList![lastIndex];
          if (lastPost.isEditing) {
            lastPost.resetPost();
          }
        }
        lastIndex = index;
        preloadImages(
          context: context,
          index: index,
          posts: widget.controller.itemList!,
          size: ImageSize.sample,
        );
      },
    );
  }
}
