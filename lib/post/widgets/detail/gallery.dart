import 'dart:math';

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
  bool hasRequestedNextPage = false;
  late int lastIndex = widget.initialPage;
  late PageController pageController =
      PageController(initialPage: widget.initialPage);

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void loadNextPage(int index) {
    if (!hasRequestedNextPage) {
      int newPageRequestTriggerIndex =
          max(0, widget.controller.posts?.length ?? 0 - 3);

      if (widget.controller.nextPageKey != null &&
          index >= newPageRequestTriggerIndex) {
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          widget.controller
              .notifyPageRequestListeners(widget.controller.nextPageKey!);
        });
        hasRequestedNextPage = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) => PageView.builder(
        controller: pageController,
        itemBuilder: (context, index) {
          loadNextPage(index);
          return PostDetail(
            post: widget.controller.posts![index],
            controller: widget.controller,
            onPageChanged: (index) => ModalRoute.of(context)!.isCurrent
                ? pageController.animateToPage(index,
                    duration: defaultAnimationDuration, curve: Curves.easeInOut)
                : pageController.jumpToPage(index),
          );
        },
        itemCount: widget.controller.posts?.length ?? 0,
        onPageChanged: (index) {
          if (widget.controller.posts!.isNotEmpty) {
            Post lastPost = widget.controller.posts![lastIndex];
            if (lastPost.isEditing) {
              lastPost.resetPost();
            }
          }
          lastIndex = index;
          preloadImages(
            context: context,
            index: index,
            posts: widget.controller.posts!,
            size: ImageSize.sample,
          );
            },
          ),
    );
  }
}
