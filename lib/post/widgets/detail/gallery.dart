import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class PostDetailGallery extends StatefulWidget {
  const PostDetailGallery({
    required this.controller,
    this.initialPage,
    this.pageController,
    this.onPageChanged,
  }) : assert(
          initialPage == null || pageController == null,
          'Cannot pass both initialPage and pageController',
        );

  final PostsController controller;
  final int? initialPage;
  final PageController? pageController;
  final ValueChanged<int>? onPageChanged;

  @override
  State<PostDetailGallery> createState() => _PostDetailGalleryState();
}

class _PostDetailGalleryState extends State<PostDetailGallery> {
  late PageController pageController = widget.pageController ??
      PageController(initialPage: widget.initialPage ?? 0);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.controller,
      child: Consumer<PostsController>(
        builder: (context, controller, child) => GalleryButtons(
          controller: pageController,
          child: PagedPageView(
            pageController: pageController,
            pagingController: widget.controller.paging,
            builderDelegate: defaultPagedChildBuilderDelegate<Post>(
              pagingController: controller.paging,
              onEmpty: const Text('No posts'),
              onError: const Text('Failed to load posts'),
              itemBuilder: (context, item, index) => SubScrollController(
                builder: (context, scrollController) => PrimaryScrollController(
                  controller: scrollController,
                  child: PostDetail(
                    post: item,
                    onTapImage: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PostsRouteConnector(
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
            ),
            onPageChanged: (index) {
              widget.onPageChanged?.call(index);
              preloadPostImages(
                context: context,
                index: index,
                posts: controller.items!,
                size: PostImageSize.sample,
              );
            },
          ),
        ),
      ),
    );
  }
}
