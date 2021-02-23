import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/interface/cross_fade.dart';
import 'package:e1547/post.dart';
import 'package:e1547/post/detail/appbar.dart';
import 'package:e1547/post/detail/overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import 'video_frame.dart';

class PostPhotoGallery extends StatefulWidget {
  final int index;
  final List<Post> posts;
  final PageController controller;

  PostPhotoGallery({this.index = 0, @required this.posts, this.controller});

  @override
  _PostPhotoGalleryState createState() => _PostPhotoGalleryState();
}

class _PostPhotoGalleryState extends State<PostPhotoGallery> {
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
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
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
              onFrameToggle: (shown) => toggleFrame(shown: shown),
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
              showChild: post.controller.value.initialized,
              child: AspectRatio(
                aspectRatio: post.controller.value.aspectRatio,
                child: VideoPlayer(post.controller),
              ),
              secondChild: CachedNetworkImage(
                imageUrl: post.sample.value.url,
                placeholder: (context, url) => Center(
                    child: Container(
                  height: 26,
                  width: 26,
                  child: CircularProgressIndicator(),
                )),
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
          return PostOverlay(
              post: widget.posts[index],
              builder: (post) {
                switch (widget.posts[index].type) {
                  case ImageType.Image:
                    return PostPhoto(post);
                  case ImageType.Video:
                    return Hero(
                      tag: 'image_${widget.posts[index].id}',
                      child: video(post),
                    );
                  case ImageType.Unsupported:
                  default:
                    return Container();
                }
              });
        },
        onPageChanged: (index) {
          int reach = 2;
          for (int i = -(reach + 1); i < reach; i++) {
            int target = index + 1 + i;
            if (0 < target && target < widget.posts.length) {
              String url = widget.posts[target].file.value.url;
              if (url != null) {
                precacheImage(
                  CachedNetworkImageProvider(url),
                  context,
                );
              }
            }
          }
          if (widget.controller != null) {
            widget.controller.jumpToPage(index);
          }
          current.value = index;
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
