import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:flutter/material.dart';

class PostDetailGallery extends StatefulWidget {
  final PostController controller;
  final int initialPage;

  PostDetailGallery({required this.controller, this.initialPage = 0});

  @override
  _PostDetailGalleryState createState() => _PostDetailGalleryState();
}

class _PostDetailGalleryState extends State<PostDetailGallery> {
  late int lastIndex;
  late PageController controller;

  @override
  void initState() {
    super.initState();
    lastIndex = widget.initialPage;
    controller = PageController(
        initialPage: widget.initialPage, viewportFraction: 1.000000000001);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        Widget pageBuilder(BuildContext context, int index) {
          if (index == widget.controller.itemList!.length - 1) {
            widget.controller
                .notifyPageRequestListeners(widget.controller.nextPageKey!);
          }
          return PostDetail(
            post: widget.controller.itemList![index],
            controller: widget.controller,
            changePage: (index) => ModalRoute.of(context)!.isCurrent
                ? controller.animateToPage(index,
                    duration: defaultAnimationDuration, curve: Curves.easeInOut)
                : controller.jumpToPage(index),
          );
        }

        return PageView.builder(
          controller: controller,
          itemBuilder: pageBuilder,
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
      },
    );
  }
}
