import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailImage extends StatelessWidget {
  final Post post;

  const DetailImage({required this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(child: PostImageWidget(post: post, size: ImageSize.sample)),
      ],
    );
  }
}

class DetailVideo extends StatelessWidget {
  final Post post;

  const DetailVideo({required this.post});

  @override
  Widget build(BuildContext context) {
    return PostVideoLoader(
      post: post,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: post.controller != null
            ? () => post.controller!.value.isPlaying
                ? post.controller!.pause()
                : post.controller!.play()
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PostVideoWidget(post: post),
                  SafeCrossFade(
                    showChild: post.controller != null,
                    builder: (context) => Padding(
                      padding: EdgeInsets.all(8),
                      child: VideoPlayButton(videoController: post.controller!),
                    ),
                    secondChild: SizedCircularProgressIndicator(size: 24),
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

  const DetailImageToggle({required this.post});

  @override
  _DetailImageToggleState createState() => _DetailImageToggleState();
}

class _DetailImageToggleState extends State<DetailImageToggle> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.post.flags.deleted) {
      return CrossFade(
        showChild: (widget.post.file.url == null ||
            !widget.post.isVisible ||
            widget.post.isAllowed),
        duration: Duration(milliseconds: 200),
        child: Card(
          color: widget.post.isAllowed ? Colors.black12 : Colors.transparent,
          elevation: 0,
          child: InkWell(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(
                    widget.post.isAllowed
                        ? Icons.visibility_off
                        : Icons.visibility,
                    size: 16,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: widget.post.isAllowed ? Text('hide') : Text('show'),
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

              if (widget.post.file.url == null) {
                if (await settings.customHost.value == null) {
                  await setCustomHost(context);
                }
                if (await settings.customHost.value != null) {
                  Post replacement;
                  replacement = await client.post(widget.post.id, unsafe: true);
                  widget.post.file = replacement.file;
                  widget.post.preview = replacement.preview;
                  widget.post.sample = replacement.sample;
                  widget.post.notifyListeners();
                }
              } else {
                widget.post.isAllowed = !widget.post.isAllowed;
                widget.post.controller?.pause();
                widget.post.notifyListeners();
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
  final VoidCallback? onOpen;

  const DetailImageOverlay(
      {required this.post, required this.child, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    VoidCallback? onTap;

    if (post.file.url != null && post.isVisible) {
      onTap = post.type == PostType.Unsupported
          ? () => launch(post.file.url!)
          : onOpen;
    }

    return AnimatedBuilder(
        child: child,
        animation: Listenable.merge([
          post.controller,
        ]),
        builder: (context, child) {
          Widget fullscreenButton() {
            if (post.type == PostType.Video && onTap != null) {
              return CrossFade(
                showChild: post.file.url != null && post.isVisible,
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
                onTap: post.type == PostType.Video
                    ? () => post.controller!.value.isPlaying
                        ? post.controller!.pause()
                        : post.controller!.play()
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
  final VoidCallback? onTap;

  const DetailImageDisplay({required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: post,
      builder: (context, child) {
        return DetailImageOverlay(
          onOpen: onTap,
          post: post,
          child: ConstrainedBox(
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
                  flightShuttleBuilder: imageFlightShuttleBuilder,
                  tag: post.hero,
                  child: post.type == PostType.Video
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
