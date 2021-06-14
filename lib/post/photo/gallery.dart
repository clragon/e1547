import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/post/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class PostPhotoGallery extends StatefulWidget {
  final int index;
  final List<Post> posts;
  final Function(int index) onPageChanged;

  PostPhotoGallery({this.index = 0, @required this.posts, this.onPageChanged});

  @override
  _PostPhotoGalleryState createState() => _PostPhotoGalleryState();
}

class _PostPhotoGalleryState extends State<PostPhotoGallery> with RouteAware {
  ValueNotifier<bool> showFrame = ValueNotifier(false);
  ValueNotifier<int> current = ValueNotifier(null);

  void toggleFrame({bool shown}) {
    showFrame.value = shown ?? !showFrame.value;
    SystemChrome.setEnabledSystemUIOverlays(
        showFrame.value ? SystemUiOverlay.values : []);
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    current.value = widget.index;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void didPop() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  @override
  void dispose() {
    super.dispose();
    routeObserver.unsubscribe(this);
  }

  @override
  Widget build(BuildContext context) {
    Widget frame(Widget picture) {
      return ValueListenableBuilder(
        valueListenable: current,
        builder: (context, value, child) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: ValueListenableBuilder(
                valueListenable: showFrame,
                builder: (context, visible, child) => CrossFade(
                  duration: Duration(milliseconds: 200),
                  showChild: visible,
                  child: child,
                ),
                child: Builder(
                  builder: (context) {
                    return PostAppBar(
                        post: widget.posts[value], canEdit: false);
                  },
                ),
              ),
            ),
            body: VideoFrame(
              child: child,
              post: widget.posts[value],
              onToggle: (shown) => toggleFrame(shown: shown),
            ),
          );
        },
        child: picture,
      );
    }

    Widget video(Post post) {
      return ValueListenableBuilder(
        valueListenable: post.controller,
        builder: (context, value, child) => Stack(
          alignment: Alignment.center,
          children: [
            CrossFade(
              showChild: post.controller.value.isInitialized,
              child: AspectRatio(
                aspectRatio: post.controller.value.aspectRatio,
                child: VideoPlayer(post.controller),
              ),
              secondChild: CachedNetworkImage(
                imageUrl: post.sample.value.url,
                progressIndicatorBuilder: (context, url, progress) => Center(
                  child: SizedCircularProgressIndicator(
                    size: 26,
                    value: progress.progress,
                  ),
                ),
                errorWidget: (context, url, error) =>
                    Center(child: Icon(Icons.error_outline)),
              ),
            ),
          ],
        ),
      );
    }

    Widget gallery() {
      return PageView.builder(
        itemCount: widget.posts.length,
        controller: PageController(initialPage: widget.index),
        physics: BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return ImageOverlay(
              post: widget.posts[index],
              builder: (post) {
                switch (widget.posts[index].type) {
                  case ImageType.Image:
                    return PostPhoto(post);
                  case ImageType.Video:
                    return Hero(
                      tag: getPostHero(widget.posts[index]),
                      child: video(post),
                    );
                  case ImageType.Unsupported:
                  default:
                    return SizedBox.shrink();
                }
              });
        },
        onPageChanged: (index) {
          current.value = index;
          widget.onPageChanged(index);
          preloadImages(
            context: context,
            index: index,
            posts: widget.posts,
            size: ImageSize.file,
          );
        },
      );
    }

    return WillPopScope(
      onWillPop: () async {
        SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
        return true;
      },
      child: frame(gallery()),
    );
  }
}
