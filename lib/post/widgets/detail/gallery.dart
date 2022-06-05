import 'dart:math';

import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PostDetailGallery extends StatefulWidget {
  final PostController controller;
  final int? initialPage;
  final PageController? pageController;
  final ValueChanged<int>? onPageChanged;

  const PostDetailGallery({
    required this.controller,
    this.initialPage,
    this.pageController,
    this.onPageChanged,
  }) : assert(initialPage == null || pageController == null);

  @override
  State<PostDetailGallery> createState() => _PostDetailGalleryState();
}

class _PostDetailGalleryState extends State<PostDetailGallery>
    with ListenerCallbackMixin, ImagePreloader {
  bool hasRequestedNextPage = false;
  late PageController pageController = widget.pageController ??
      PageController(initialPage: widget.initialPage ?? 0);

  @override
  Map<Listenable, VoidCallback> get listeners => {
        widget.controller: updateRequest,
      };

  void updateRequest() {
    if (widget.controller.value.status == PagingStatus.ongoing) {
      hasRequestedNextPage = false;
    }
  }

  void loadNextPage(int index) {
    if (!hasRequestedNextPage) {
      int newPageRequestTriggerIndex =
          max(0, widget.controller.itemList?.length ?? 0 - 3);

      if (widget.controller.nextPageKey != null &&
          index >= newPageRequestTriggerIndex) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
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
          return PrimaryScrollController(
            controller: ScrollController(),
            child: PostDetail(
              post: widget.controller.itemList![index],
              controller: widget.controller,
              onTapImage: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PostFullscreenGallery(
                    controller: widget.controller,
                    initialPage: index,
                    onPageChanged: pageController.jumpToPage,
                  ),
                ),
              ),
            ),
          );
        },
        itemCount: widget.controller.itemList?.length ?? 0,
        onPageChanged: (index) => preloadImages(
          index: index,
          posts: widget.controller.itemList!,
          size: ImageSize.sample,
        ),
      ),
    );
  }
}
