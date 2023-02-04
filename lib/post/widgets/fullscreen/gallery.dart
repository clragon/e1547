import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class PostFullscreenGallery extends StatefulWidget {
  const PostFullscreenGallery({
    required this.controller,
    this.initialPage,
    this.pageController,
    this.onPageChanged,
    this.showFrame,
  }) : assert(initialPage == null || pageController == null);

  final PostsController controller;
  final int? initialPage;
  final PageController? pageController;
  final ValueChanged<int>? onPageChanged;
  final bool? showFrame;

  @override
  State<PostFullscreenGallery> createState() => _PostFullscreenGalleryState();
}

class _PostFullscreenGalleryState extends State<PostFullscreenGallery> {
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
        child: ScaffoldFrame(child: child!),
      ),
      child: ChangeNotifierProvider.value(
        value: widget.controller,
        child: Consumer<PostsController>(
          builder: (context, controller, child) => GalleryButtonWrapper(
            controller: pageController,
            child: PageView.builder(
              itemCount: controller.itemList?.length ?? 0,
              controller: widget.pageController ?? pageController,
              itemBuilder: (context, index) => PostFullscreen(
                post: controller.itemList![index],
              ),
              onPageChanged: (index) {
                currentPage.value = index;
                widget.onPageChanged?.call(index);
                if (controller.itemList != null) {
                  preloadPostImages(
                    context: context,
                    index: index,
                    posts: controller.itemList!,
                    size: PostImageSize.file,
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
