import 'dart:math';

import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

class PostDetailGallery extends StatefulWidget {
  final PostsController controller;
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
    with PostImagePreloader {
  bool hasRequestedNextPage = false;
  late PageController pageController = widget.pageController ??
      PageController(initialPage: widget.initialPage ?? 0);

  void loadNextPage(int index) {
    if (!hasRequestedNextPage) {
      int newPageRequestTriggerIndex =
          max(0, ((widget.controller.itemList?.length ?? 0) - 3) - 1);
      if (widget.controller.nextPageKey != null &&
          index >= newPageRequestTriggerIndex) {
        WidgetsBinding.instance.addPostFrameCallback((_) => widget.controller
            .notifyPageRequestListeners(widget.controller.nextPageKey!));
        hasRequestedNextPage = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.controller,
      child: Consumer<PostsController>(
        builder: (context, controller, child) => ListenableListener(
          listener: () {
            if (widget.controller.value.status == PagingStatus.ongoing) {
              hasRequestedNextPage = false;
            }
          },
          listenable: controller,
          child: PageView.builder(
            controller: pageController,
            itemBuilder: (context, index) {
              loadNextPage(index);
              return PrimaryScrollController(
                controller: ScrollController(),
                child: PostProvider(
                  id: controller.itemList![index].id,
                  child: Consumer<PostController>(
                    builder: (context, post, child) => PostDetail(
                      post: post,
                      onTapImage: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PostDetailConnector(
                            controller: controller,
                            child: PostFullscreenGallery(
                              controller: controller,
                              initialPage: index,
                              onPageChanged: pageController.jumpToPage,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
            itemCount: controller.itemList?.length ?? 0,
            onPageChanged: (index) {
              widget.onPageChanged?.call(index);
              preloadPostImages(
                index: index,
                posts: controller.itemList!,
                size: PostImageSize.sample,
              );
            },
          ),
        ),
      ),
    );
  }
}
