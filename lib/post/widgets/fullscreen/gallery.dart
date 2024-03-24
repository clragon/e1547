import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class PostFullscreenGallery extends StatelessWidget {
  const PostFullscreenGallery({
    super.key,
    required this.controller,
    this.initialPage,
    this.pageController,
    this.onPageChanged,
  }) : assert(
          initialPage == null || pageController == null,
          'Cannot pass both initialPage and pageController',
        );

  final PostController controller;
  final int? initialPage;
  final PageController? pageController;
  final ValueChanged<int>? onPageChanged;

  @override
  Widget build(BuildContext context) {
    return SubDefault<PageController>(
      value: pageController,
      create: () => PageController(initialPage: initialPage ?? 0),
      builder: (context, pageController) => ScaffoldFrame(
        child: ChangeNotifierProvider.value(
          value: controller,
          child: Consumer<PostController>(
            builder: (context, controller, child) => GalleryButtons(
              controller: pageController,
              child: PageView.builder(
                itemCount: controller.items?.length ?? 0,
                controller: pageController,
                itemBuilder: (context, index) => PostFullscreen(
                  post: controller.items![index],
                ),
                onPageChanged: (index) {
                  onPageChanged?.call(index);
                  if (controller.items != null) {
                    preloadPostImages(
                      context: context,
                      index: index,
                      posts: controller.items!,
                      size: PostImageSize.file,
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
