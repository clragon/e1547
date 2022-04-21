import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PostFullscreenGallery extends StatefulWidget {
  final int initialPage;
  final PostController controller;
  final Function(int index)? onPageChanged;

  const PostFullscreenGallery({
    required this.controller,
    this.initialPage = 0,
    this.onPageChanged,
  });

  @override
  _PostFullscreenGalleryState createState() => _PostFullscreenGalleryState();
}

class _PostFullscreenGalleryState extends State<PostFullscreenGallery>
    with RouteAware {
  late PageController pageController =
      PageController(initialPage: widget.initialPage);
  late ValueNotifier<int> currentPage = ValueNotifier(widget.initialPage);
  late FrameController frameController;

  Future<void> toggleFrame(bool shown) async {
    if (shown) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    }
  }

  @override
  void initState() {
    super.initState();
    toggleFrame(false);
    frameController = FrameController(onToggle: toggleFrame);
    SystemChrome.setSystemUIChangeCallback(
        (hidden) async => frameController.toggleFrame(shown: !hidden));
  }

  late NavigationController navigation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    navigation = NavigationData.of(context);
    navigation.routeObserver
        .subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    navigation.routeObserver.unsubscribe(this);
    SystemChrome.setSystemUIChangeCallback(null);
    frameController.dispose();
    pageController.dispose();
    currentPage.dispose();
    super.dispose();
  }

  @override
  void didPop() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

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
                child: child!,
                post: widget.controller.itemList![value],
                controller: frameController,
              )
            : SizedBox.shrink(),
      ),
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, child) => PageView.builder(
          itemCount: widget.controller.itemList?.length,
          controller: pageController,
          itemBuilder: (context, index) => PostFullscreen(
            post: widget.controller.itemList![index],
            controller: widget.controller,
          ),
          onPageChanged: (index) {
            currentPage.value = index;
            widget.onPageChanged?.call(index);
            if (widget.controller.itemList != null) {
              preloadImages(
                context: context,
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
