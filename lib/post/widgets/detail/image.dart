import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PostDetailImage extends StatelessWidget {
  final Post post;

  const PostDetailImage({required this.post});

  @override
  Widget build(BuildContext context) {
    return PostImageWidget(
      post: post,
      size: ImageSize.sample,
      fit: BoxFit.cover,
    );
  }
}

class PostDetailVideo extends StatelessWidget {
  final Post post;

  const PostDetailVideo({required this.post});

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
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.passthrough,
          children: [
            PostVideoWidget(post: post),
            Positioned.fill(
              child: Center(
                child: SafeCrossFade(
                  showChild: post.controller != null,
                  builder: (context) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    child: VideoButton(videoController: post.controller!),
                  ),
                  secondChild: SizedCircularProgressIndicator(size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PostDetailImageToggle extends StatefulWidget {
  final Post post;

  const PostDetailImageToggle({required this.post});

  @override
  _PostDetailImageToggleState createState() => _PostDetailImageToggleState();
}

class _PostDetailImageToggleState extends State<PostDetailImageToggle> {
  bool loading = false;
  Post? replacement;

  Future<void> onToggle() async {
    setState(() {
      loading = true;
    });
    if (widget.post.file.url == null) {
      if (settings.customHost.value == null) {
        await setCustomHost(context);
      }
      if (settings.customHost.value != null) {
        if (replacement == null) {
          replacement = await client.post(widget.post.id, unsafe: true);
        }
        widget.post.file.url = replacement!.file.url;
        widget.post.preview.url = replacement!.preview.url;
        widget.post.sample.url = replacement!.sample.url;
        if (!widget.post.isBlacklisted) {
          widget.post.isAllowed = !widget.post.isAllowed;
        }
        widget.post.notifyListeners();
      }
    } else {
      widget.post.isAllowed = !widget.post.isAllowed;
      widget.post.controller?.pause();
      widget.post.notifyListeners();
    }
    if (!widget.post.isAllowed && replacement != null) {
      widget.post.file.url = null;
      widget.post.preview.url = null;
      widget.post.sample.url = null;
      widget.post.notifyListeners();
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.post.flags.deleted) {
      return AnimatedSelector(
        animation: widget.post,
        selector: () => [widget.post.isAllowed, widget.post.file.url],
        builder: (context, child) => CrossFade(
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
                        size: 16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Text(widget.post.isAllowed ? 'hide' : 'show'),
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
              onTap: onToggle,
            ),
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}

class PostDetailImageOverlay extends StatelessWidget {
  final Post post;
  final Widget child;
  final VoidCallback? onOpen;

  const PostDetailImageOverlay(
      {required this.post, required this.child, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    VoidCallback? onTap;

    if (post.file.url != null && post.isVisible) {
      onTap = post.type == PostType.unsupported
          ? () => launch(post.file.url!)
          : onOpen;
    }

    return AnimatedBuilder(
      child: child,
      animation: Listenable.merge([post.controller]),
      builder: (context, child) {
        Widget fullscreenButton() {
          if (post.type == PostType.video && onTap != null) {
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
                      color: Colors.white,
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
              onTap: post.type == PostType.video
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
                  PostDetailImageToggle(post: post),
                ],
              ),
              bottom: 0,
              right: 5,
            )
          ],
        );
      },
    );
  }
}

class PostDetailImageDisplay extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;

  const PostDetailImageDisplay({required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: post,
      builder: (context, child) {
        Size screenSize = MediaQuery.of(context).size;
        return PostDetailImageOverlay(
          onOpen: onTap,
          post: post,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (screenSize.height / 2),
              maxHeight: screenSize.width > screenSize.height
                  ? screenSize.height * 0.8
                  : double.infinity,
            ),
            child: ImageOverlay(
              post: post,
              builder: (context) => Center(
                child: Hero(
                  tag: post.hero,
                  child: post.type == PostType.video
                      ? PostDetailVideo(post: post)
                      : PostDetailImage(post: post),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
