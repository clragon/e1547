import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/data/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PostFullscreenGallery extends StatefulWidget {
  final int index;
  final List<Post> posts;
  final Function(int index)? onPageChanged;

  const PostFullscreenGallery(
      {this.index = 0, required this.posts, this.onPageChanged});

  @override
  _PostFullscreenGalleryState createState() => _PostFullscreenGalleryState();
}

class _PostFullscreenGalleryState extends State<PostFullscreenGallery>
    with RouteAware {
  late ValueNotifier<int> current = ValueNotifier(widget.index);
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
    // should add Colors.black26 to statusbar
    return ValueListenableBuilder(
      valueListenable: current,
      builder: (context, int value, child) => Theme(
        data: Theme.of(context).copyWith(
          appBarTheme: AppBarTheme(
            systemOverlayStyle: defaultUIStyle(Theme.of(context)).copyWith(
              statusBarColor: Colors.black26,
            ),
          ),
        ),
        child: PostFullscreenFrame(
          child: child!,
          post: widget.posts[value],
          controller: frameController,
        ),
      ),
      child: PageView.builder(
        itemCount: widget.posts.length,
        controller: PageController(initialPage: widget.index),
        itemBuilder: (context, int index) =>
            PostFullscreenImageDisplay(post: widget.posts[index]),
        onPageChanged: (index) {
          current.value = index;
          widget.onPageChanged!(index);
          preloadImages(
            context: context,
            index: index,
            posts: widget.posts,
            size: ImageSize.file,
          );
        },
      ),
    );
  }
}
