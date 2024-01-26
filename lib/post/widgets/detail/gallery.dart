import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class PostDetailGallery extends StatelessWidget {
  const PostDetailGallery({
    super.key,
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
  Widget build(BuildContext context) {
    return SubDefault<PageController>(
      value: pageController,
      create: () => PageController(initialPage: initialPage ?? 0),
      builder: (context, pageController) => ChangeNotifierProvider.value(
        value: controller,
        child: Consumer<PostsController>(
          builder: (context, controller, child) => GalleryButtons(
            controller: pageController,
            child: PagedPageView(
              pageController: pageController,
              pagingController: controller.paging,
              builderDelegate: defaultPagedChildBuilderDelegate<Post>(
                pagingController: controller.paging,
                pageBuilder: (context, child) => Scaffold(
                  appBar: const TransparentAppBar(child: DefaultAppBar()),
                  body: child,
                ),
                onEmpty: const Text('No posts'),
                onError: const Text('Failed to load posts'),
                itemBuilder: (context, item, index) => SubScrollController(
                  builder: (context, scrollController) =>
                      PrimaryScrollController(
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
                onPageChanged?.call(index);
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
      ),
    );
  }
}
