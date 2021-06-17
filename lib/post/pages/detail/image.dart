import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class DetailImage extends StatelessWidget {
  final Post post;

  const DetailImage({@required this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: CachedNetworkImage(
            imageUrl: post.sample.value.url,
            fit: BoxFit.contain,
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
    );
  }
}

class DetailVideo extends StatelessWidget {
  final Post post;

  const DetailVideo({@required this.post});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: post.controller,
      builder: (context, value, child) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () =>
            value.isPlaying ? post.controller.pause() : post.controller.play(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SafeCrossFade(
                    showChild: value.isInitialized,
                    builder: (context) => AspectRatio(
                      aspectRatio: value.aspectRatio,
                      child: VideoPlayer(post.controller),
                    ),
                    secondChild: DetailImage(post: post),
                  ),
                  VideoPlayButton(
                    videoController: post.controller,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailImageToggle extends StatefulWidget {
  final Post post;

  const DetailImageToggle({@required this.post});

  @override
  _DetailImageToggleState createState() => _DetailImageToggleState();
}

class _DetailImageToggleState extends State<DetailImageToggle> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.post.isDeleted) {
      return CrossFade(
        showChild: (widget.post.file.value.url == null ||
            !widget.post.isVisible ||
            widget.post.showUnsafe.value),
        duration: Duration(milliseconds: 200),
        child: Card(
          color: widget.post.showUnsafe.value
              ? Colors.black12
              : Colors.transparent,
          elevation: 0,
          child: InkWell(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(
                    widget.post.showUnsafe.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                    size: 16,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: widget.post.showUnsafe.value
                        ? Text('hide')
                        : Text('show'),
                  ),
                  CrossFade(
                    showChild: loading,
                    child: SizedCircularProgressIndicator(
                      size: 12,
                    ),
                  ),
                ],
              ),
            ),
            onTap: () async {
              setState(() {
                loading = true;
              });

              if (widget.post.file.value.url == null) {
                if (await db.customHost.value == null) {
                  await setCustomHost(context);
                }
                if (await db.customHost.value != null) {
                  Post replacement;
                  replacement = await client.post(widget.post.id, unsafe: true);
                  widget.post.file.value = replacement.file.value;
                  widget.post.preview.value = replacement.preview.value;
                  widget.post.sample.value = replacement.sample.value;
                }
              } else {
                widget.post.showUnsafe.value = !widget.post.showUnsafe.value;
              }

              setState(() {
                loading = false;
              });
            },
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}

class DetailImageOverlay extends StatelessWidget {
  final Post post;
  final Widget child;
  final void Function() onOpen;

  const DetailImageOverlay(
      {@required this.post, @required this.child, @required this.onOpen});

  @override
  Widget build(BuildContext context) {
    void Function() onTap;

    if (post.file.value.url != null && post.isVisible) {
      onTap = post.type == ImageType.Unsupported
          ? () => launch(post.file.value.url)
          : onOpen;
    }

    return AnimatedBuilder(
        child: child,
        animation: Listenable.merge([
          post.controller,
        ]),
        builder: (context, child) {
          Widget fullscreenButton() {
            if (post.type == ImageType.Video && onTap != null) {
              return CrossFade(
                showChild: post.file.value.url != null && post.isVisible,
                child: Card(
                  elevation: 0,
                  color: Colors.black12,
                  child: InkWell(
                    child: Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.fullscreen,
                        size: 24,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                    onTap: onTap,
                  ),
                ),
              );
            } else {
              return SizedBox.shrink();
            }
          }

          return Stack(
            children: [
              InkWell(
                onTap: post.type == ImageType.Video
                    ? () => post.controller.value.isPlaying
                        ? post.controller.pause()
                        : post.controller.play()
                    : onTap,
                child: IgnorePointer(child: child),
              ),
              Positioned(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    fullscreenButton(),
                    DetailImageToggle(post: post),
                  ],
                ),
                bottom: 0,
                right: 5,
              )
            ],
          );
        });
  }
}

class DetailImageDisplay extends StatelessWidget {
  final Post post;
  final void Function() onTap;

  const DetailImageDisplay({@required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        post.file,
        post.showUnsafe,
        post.isFavorite,
      ]),
      builder: (context, child) {
        return DetailImageOverlay(
          onOpen: onTap,
          post: post,
          child: Container(
            constraints: BoxConstraints(
              minHeight: (MediaQuery.of(context).size.height / 2),
              maxHeight: MediaQuery.of(context).size.width >
                      MediaQuery.of(context).size.height
                  ? MediaQuery.of(context).size.height * 0.8
                  : double.infinity,
            ),
            child: ImageOverlay(
              post: post,
              builder: (context) => Center(
                child: Hero(
                  tag: getPostHero(post),
                  child: post.type == ImageType.Video
                      ? DetailVideo(post: post)
                      : DetailImage(post: post),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
