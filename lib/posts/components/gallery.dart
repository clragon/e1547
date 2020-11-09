import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/interface/cross_fade.dart';
import 'package:e1547/posts/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icon_shadow/icon_shadow.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

class ImageGallery extends StatefulWidget {
  final int index;
  final List<Post> posts;
  final PageController controller;

  const ImageGallery({this.index = 0, @required this.posts, this.controller});

  @override
  _ImageGalleryState createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  ValueNotifier<int> current = ValueNotifier(null);
  ValueNotifier<bool> showFrame = ValueNotifier(false);
  ImageSize imageSize;
  Timer frameToggler;

  void toggleFrame({bool shown}) {
    showFrame.value = shown ?? !showFrame.value;
    showFrame.value
        ? SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values)
        : SystemChrome.setEnabledSystemUIOverlays([]);
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
    frameToggler?.cancel();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    Widget pictureFrame(Widget picture) {
      Widget frameDependant(Widget control) {
        return ValueListenableBuilder(
          valueListenable: showFrame,
          builder: (context, value, child) => CrossFade(
            duration: Duration(milliseconds: 200),
            showChild: value,
            child: child,
          ),
          child: control,
        );
      }

      Widget bottomBar() {
        return Column(mainAxisSize: MainAxisSize.min, children: [
          frameDependant(ValueListenableBuilder(
            valueListenable: widget.posts[current.value].controller,
            builder: (context, controller, child) {
              if (controller.initialized) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(controller.position.toString().substring(2, 7)),
                      Expanded(
                          child: Slider(
                        min: 0,
                        max: controller.duration.inMilliseconds.toDouble(),
                        value: controller.position.inMilliseconds.toDouble(),
                        onChangeStart: (double value) {
                          frameToggler?.cancel();
                        },
                        onChanged: (double value) {
                          widget.posts[current.value].controller
                              .seekTo(Duration(milliseconds: value.toInt()));
                        },
                        onChangeEnd: (double value) {
                          frameToggler = Timer(Duration(seconds: 2), () {
                            toggleFrame(shown: false);
                          });
                        },
                      )),
                      Text(controller.duration.toString().substring(2, 7)),
                      InkWell(
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.fullscreen_exit,
                            size: 24,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        ),
                        onTap: Navigator.of(context).maybePop,
                      ),
                    ],
                  ),
                );
              } else {
                return Container();
              }
            },
          ))
        ]);
      }

      Widget playButton() {
        return ValueListenableBuilder(
            valueListenable: widget.posts[current.value].controller,
            builder: (context, controller, child) {
              return ValueListenableBuilder(
                valueListenable: showFrame,
                builder: (context, value, child) {
                  return AnimatedOpacity(
                    duration: Duration(milliseconds: 200),
                    opacity: value || !controller.isPlaying ? 1 : 0,
                    child: value || !controller.isPlaying
                        ? child
                        : IgnorePointer(child: child),
                  );
                },
                child: InkWell(
                  onTap: () {
                    frameToggler?.cancel();
                    if (controller.isPlaying) {
                      widget.posts[current.value].controller.pause();
                      Wakelock.disable();
                    } else {
                      widget.posts[current.value].controller.play();
                      Wakelock.enable();
                      frameToggler = Timer(Duration(milliseconds: 500), () {
                        toggleFrame(shown: false);
                      });
                    }
                  },
                  child: CrossFade(
                    duration: Duration(milliseconds: 100),
                    showChild: controller.isPlaying,
                    child: CrossFade(
                      duration: Duration(milliseconds: 100),
                      showChild:
                          controller.initialized && !controller.isBuffering,
                      child: IconShadowWidget(
                        Icon(
                          Icons.pause,
                          size: 54,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        shadowColor: Colors.black,
                      ),
                      secondChild: Container(
                        height: 54,
                        width: 54,
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                    secondChild: IconShadowWidget(
                      Icon(
                        Icons.play_arrow,
                        size: 54,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      shadowColor: Colors.black,
                    ),
                  ),
                ),
              );
            });
      }

      Widget body(Widget child) {
        return MediaQuery.removeViewInsets(
          context: context,
          removeTop: true,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              frameToggler?.cancel();
              toggleFrame();
              if (widget.posts[current.value].controller != null &&
                  widget.posts[current.value].controller.value.isPlaying &&
                  widget.posts[current.value].controller.value.initialized &&
                  showFrame.value) {
                frameToggler = Timer(Duration(seconds: 2), () {
                  toggleFrame(shown: false);
                });
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                child,
                widget.posts[current.value].controller != null
                    ? playButton()
                    : Container(),
              ],
            ),
          ),
        );
      }

      return ValueListenableBuilder(
        valueListenable: current,
        builder: (context, value, child) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: frameDependant(
                postAppBar(context, widget.posts[current.value],
                    canEdit: false),
              ),
            ),
            body: body(child),
            bottomSheet: widget.posts[current.value].controller != null
                ? bottomBar()
                : null,
          );
        },
        child: picture,
      );
    }

    Widget pictureGallery() {
      return PhotoViewGallery.builder(
        scrollPhysics: BouncingScrollPhysics(),
        backgroundDecoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
        ),
        builder: (context, index) {
          ImageFile image = widget.posts[index].image.value;
          imageSize =
              (image.file['ext'] == 'webm' || image.file['ext'] == 'swf')
                  ? ImageSize.screen
                  : ImageSize.sample;
          return PhotoViewGalleryPageOptions.customChild(
            disableGestures:
                (image.file['ext'] == 'webm' || image.file['ext'] == 'swf'),
            heroAttributes: PhotoViewHeroAttributes(
              tag: 'image_${widget.posts[index].id}',
            ),
            childSize: () {
              double width;
              double height;
              switch (imageSize) {
                case ImageSize.screen:
                  width = MediaQuery.of(context).size.width;
                  height = MediaQuery.of(context).size.height;
                  break;
                case ImageSize.sample:
                  width = image.sample['width'].toDouble();
                  height = image.sample['height'].toDouble();
                  break;
                case ImageSize.full:
                  width = image.file['width'].toDouble();
                  height = image.file['height'].toDouble();
                  break;
              }
              return Size(width, height);
            }(),
            child: () {
              if (image.file['ext'] == 'swf') {
                return Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Flash is not supported',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Card(
                        child: InkWell(
                          child: Padding(
                              padding: EdgeInsets.all(8), child: Text('Open')),
                          onTap: () async => launch(widget.posts[index]
                              .url(await db.host.value)
                              .toString()),
                        ),
                      )
                    ],
                  ),
                );
              } else if (image.file['ext'] == 'webm') {
                return ValueListenableBuilder(
                  valueListenable: widget.posts[index].controller,
                  builder: (context, value, child) => Stack(
                    alignment: Alignment.center,
                    children: [
                      CrossFade(
                        showChild:
                            widget.posts[index].controller.value.initialized,
                        child: AspectRatio(
                          aspectRatio:
                              widget.posts[index].controller.value.aspectRatio,
                          child: VideoPlayer(widget.posts[index].controller),
                        ),
                        secondChild: CachedNetworkImage(
                          imageUrl:
                              widget.posts[index].image.value.sample['url'],
                          placeholder: (context, url) => Center(
                              child: Container(
                            height: 26,
                            width: 26,
                            child: const CircularProgressIndicator(),
                          )),
                          errorWidget: (context, url, error) =>
                              Center(child: Icon(Icons.error_outline)),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                imageSize = ImageSize.sample;
                return CachedNetworkImage(
                  fadeInDuration: Duration(milliseconds: 0),
                  fadeOutDuration: Duration(milliseconds: 0),
                  imageUrl: widget.posts[index].image.value.file['url'],
                  imageBuilder: (context, provider) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        imageSize = ImageSize.full;
                      });
                    });
                    return Image(image: provider);
                  },
                  placeholder: (context, chunk) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        CachedNetworkImage(
                          imageUrl:
                              widget.posts[index].image.value.sample['url'],
                          imageBuilder: (context, provider) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              setState(() {
                                imageSize = ImageSize.sample;
                              });
                            });
                            return Image(image: provider);
                          },
                          placeholder: (context, chunk) => Center(
                            child: Container(
                                // TODO: using zoom level, calculate accurate size
                                height: 26 * window.devicePixelRatio,
                                width: 26 * window.devicePixelRatio,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2 * window.devicePixelRatio,
                                )),
                          ),
                          errorWidget: (context, url, error) =>
                              Center(child: Icon(Icons.error_outline)),
                        ),
                        Container(
                          alignment: Alignment.bottomCenter,
                          child: LinearProgressIndicator(
                            minHeight: 3 * window.devicePixelRatio,
                          ),
                        ),
                      ],
                    );
                  },
                  errorWidget: (context, url, error) =>
                      Center(child: Icon(Icons.error_outline)),
                );
              }
            }(),
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 6,
          );
        },
        itemCount: widget.posts.length,
        pageController: PageController(initialPage: widget.index),
        onPageChanged: (index) {
          frameToggler?.cancel();
          int precache = 2;
          for (int i = -precache - 1; i < precache; i++) {
            int target = index + 1 + i;
            if (target > 0 && target < widget.posts.length) {
              String ext = widget.posts[target].image.value.file['ext'];
              if (ext != 'webm' && ext != 'swf') {
                precacheImage(
                  CachedNetworkImageProvider(
                      widget.posts[target].image.value.file['url']),
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
      onWillPop: () {
        SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
        return Future.value(true);
      },
      child: pictureFrame(pictureGallery()),
    );
  }
}
