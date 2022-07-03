import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

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
    with ImagePreloader {
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
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, child) => PageView.builder(
          itemCount: widget.controller.itemList?.length,
          controller: widget.pageController ?? pageController,
          itemBuilder: (context, index) => PostFullscreenBody(
            post: PostController(
              id: widget.controller.itemList![index].id,
              parent: widget.controller,
            ),
          ),
          onPageChanged: (index) {
            currentPage.value = index;
            widget.onPageChanged?.call(index);
            if (widget.controller.itemList != null) {
              preloadImages(
                index: index,
                posts: widget.controller.itemList!,
                size: ImageSize.file,
              );
            }
          },
        ),
      ),
    );
  }
}
