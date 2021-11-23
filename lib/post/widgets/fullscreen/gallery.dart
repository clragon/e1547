import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/data/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

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
  late ValueNotifier<int> current = ValueNotifier(widget.initialPage);
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
    if (settings.hideSystemUI.value) {
      toggleFrame(false);
      frameController = FrameController(onToggle: toggleFrame);
      SystemChrome.setSystemUIChangeCallback((hidden) async {
        frameController.toggleFrame(shown: !hidden);
      });
    } else {
      frameController = FrameController();
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    frameController.dispose();
    SystemChrome.setSystemUIChangeCallback(null);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didPop() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: current,
      builder: (context, int value, child) => Theme(
        data: Theme.of(context).copyWith(
          appBarTheme: AppBarTheme(
            systemOverlayStyle: defaultUIStyle(Theme.of(context)).copyWith(
              statusBarIconBrightness: Brightness.light,
              statusBarColor: Colors.black26,
            ),
          ),
        ),
        child: widget.controller.posts != null
            ? PostFullscreenFrame(
                child: child!,
                post: widget.controller.posts![value],
                controller: frameController,
              )
            : SizedBox.shrink(),
      ),
      child: PagedPageView(
        addAutomaticKeepAlives: false,
        builderDelegate: PagedChildBuilderDelegate<Post>(
          itemBuilder: (context, post, index) =>
              PostFullscreenImageDisplay(post: post),
          firstPageProgressIndicatorBuilder: (context) => Material(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedCircularProgressIndicator(size: 28),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Loading posts'),
                ),
              ],
            ),
          ),
          newPageProgressIndicatorBuilder: (context) => Material(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedCircularProgressIndicator(size: 28),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Loading posts'),
                ),
              ],
            ),
          ),
          noItemsFoundIndicatorBuilder: (context) => IconMessage(
            icon: Icon(Icons.clear),
            title: Text('No posts'),
          ),
          firstPageErrorIndicatorBuilder: (context) => IconMessage(
            icon: Icon(Icons.warning_amber_outlined),
            title: Text('Failed to load posts'),
            action: PagedChildBuilderRetryButton(widget.controller),
          ),
          newPageErrorIndicatorBuilder: (context) => IconMessage(
            direction: Axis.horizontal,
            icon: Icon(Icons.warning_amber_outlined),
            title: Text('Failed to load posts'),
            action: PagedChildBuilderRetryButton(widget.controller),
          ),
        ),
        pagingController: widget.controller,
        pageController: pageController,
        onPageChanged: (index) {
          current.value = index;
          widget.onPageChanged?.call(index);
          if (widget.controller.posts != null) {
            preloadImages(
              context: context,
              index: index,
              posts: widget.controller.posts!,
              size: ImageSize.file,
            );
          }
        },
      ),
    );
  }
}
