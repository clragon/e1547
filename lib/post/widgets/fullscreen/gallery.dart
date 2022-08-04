import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PostFullscreenGallery extends StatefulWidget {
  final PostsController controller;
  final int? initialPage;
  final PageController? pageController;
  final ValueChanged<int>? onPageChanged;

  const PostFullscreenGallery({
    required this.controller,
    this.initialPage,
    this.pageController,
    this.onPageChanged,
  }) : assert(initialPage == null || pageController == null);

  @override
  State<PostFullscreenGallery> createState() => _PostFullscreenGalleryState();
}

class _PostFullscreenGalleryState extends State<PostFullscreenGallery>
    with PostImagePreloader {
  late PageController pageController = widget.pageController ??
      PageController(initialPage: widget.initialPage ?? 0);
  late ValueNotifier<int> currentPage = ValueNotifier(widget.initialPage ?? 0);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: currentPage,
      builder: (context, value, child) => Theme(
        data: Theme.of(context).copyWith(
          appBarTheme: Theme.of(context).appBarTheme.copyWith(
                systemOverlayStyle:
                    Theme.of(context).appBarTheme.systemOverlayStyle!.copyWith(
                          statusBarIconBrightness: Brightness.light,
                          statusBarColor: Colors.black26,
                        ),
              ),
        ),
        child: widget.controller.itemList != null
            ? PostFullscreenFrame(
                post: widget.controller.itemList![value],
                child: child!,
              )
            : const SizedBox.shrink(),
      ),
      child: ChangeNotifierProvider.value(
        value: widget.controller,
        child: Consumer<PostsController>(
          builder: (context, controller, child) => PageView.builder(
            itemCount: controller.itemList?.length,
            controller: widget.pageController ?? pageController,
            itemBuilder: (context, index) => PostProvider(
              id: controller.itemList![index].id,
              child: Consumer<PostController>(
                builder: (context, post, child) => PostFullscreenBody(
                  post: post,
                ),
              ),
            ),
            onPageChanged: (index) {
              currentPage.value = index;
              widget.onPageChanged?.call(index);
              if (controller.itemList != null) {
                preloadPostImages(
                  index: index,
                  posts: controller.itemList!,
                  size: ImageSize.file,
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
