import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';

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
        onTap: post.getVideo(context) != null
            ? () => post.getVideo(context)!.value.isPlaying
                ? post.getVideo(context)!.pause()
                : post.getVideo(context)!.play()
            : null,
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.passthrough,
          children: [
            PostVideoWidget(post: post),
            Positioned.fill(
              child: Center(
                child: CrossFade.builder(
                  showChild: post.getVideo(context) != null,
                  builder: (context) => Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    child:
                        VideoButton(videoController: post.getVideo(context)!),
                  ),
                  secondChild: const SizedCircularProgressIndicator(size: 24),
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
  final PostController post;

  const PostDetailImageToggle({required this.post});

  @override
  State<PostDetailImageToggle> createState() => _PostDetailImageToggleState();
}

class _PostDetailImageToggleState extends State<PostDetailImageToggle> {
  bool loading = false;
  Post? replacement;

  Post get post => widget.post.value;

  Future<void> onToggle() async {
    setState(() {
      loading = true;
    });
    if (post.file.url == null) {
      if (settings.customHost.value == null) {
        await setCustomHost(context);
      }
      if (settings.customHost.value != null) {
        replacement ??= await client.post(post.id, unsafe: true);
        if (!widget.post.isDenied) {
          widget.post.isAllowed = true;
        }
        widget.post.value = post.copyWith(
          fileRaw: post.fileRaw.copyWith(url: replacement!.fileRaw.url),
          preview: post.preview.copyWith(url: replacement!.preview.url),
          sample: post.sample.copyWith(url: replacement!.sample.url),
        );
      }
    } else {
      if (widget.post.isAllowed) {
        widget.post.isAllowed = false;
        if (replacement != null) {
          widget.post.value = post.copyWith(
            fileRaw: post.fileRaw.copyWith(url: null),
            preview: post.preview.copyWith(url: null),
            sample: post.sample.copyWith(url: null),
          );
        }
      } else {
        widget.post.isAllowed = true;
      }
      post.getVideo(context)?.pause();
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!post.flags.deleted) {
      return AnimatedBuilder(
        animation: widget.post,
        builder: (context, child) => CrossFade(
          showChild: post.file.url == null ||
              (!post.isFavorited &&
                  (widget.post.isDenied || widget.post.isAllowed)),
          duration: const Duration(milliseconds: 200),
          child: Card(
            color: widget.post.isAllowed ? Colors.black12 : Colors.transparent,
            elevation: 0,
            child: InkWell(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Icon(
                        widget.post.isAllowed
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 16,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text(widget.post.isAllowed ? 'hide' : 'show'),
                    ),
                    CrossFade(
                      showChild: loading,
                      child: const SizedCircularProgressIndicator(
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

class PostDetailImageButtons extends StatelessWidget {
  final PostController post;
  final Widget child;
  final VoidCallback? onOpen;

  const PostDetailImageButtons({
    required this.post,
    required this.child,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([post, post.value.getVideo(context)]),
      builder: (context, child) {
        VoidCallback? onTap;

        bool visible = post.value.file.url != null &&
            (!post.isDenied || post.value.isFavorited);

        if (visible) {
          onTap = post.value.type == PostType.unsupported
              ? () => launch(post.value.file.url!)
              : onOpen;
        }

        Widget fullscreenButton() {
          if (post.value.type == PostType.video && onTap != null) {
            return CrossFade(
              showChild: visible,
              child: Card(
                elevation: 0,
                color: Colors.black12,
                child: InkWell(
                  onTap: onTap,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.fullscreen,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        }

        Widget muteButton() {
          return CrossFade.builder(
            showChild: post.value.type == PostType.video &&
                post.value.file.url != null,
            builder: (context) => Card(
              elevation: 0,
              color: Colors.black12,
              child: VideoHandlerVolumeControl(
                videoController: post.value.getVideo(context)!,
              ),
            ),
          );
        }

        return Stack(
          fit: StackFit.passthrough,
          children: [
            InkWell(
              onTap: post.value.type == PostType.video
                  ? () => post.value.getVideo(context)!.value.isPlaying
                      ? post.value.getVideo(context)!.pause()
                      : post.value.getVideo(context)!.play()
                  : onTap,
              child: IgnorePointer(child: child),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    muteButton(),
                    const Spacer(),
                    fullscreenButton(),
                    PostDetailImageToggle(post: post),
                  ],
                ),
              ),
            )
          ],
        );
      },
      child: child,
    );
  }
}

class PostDetailImageDisplay extends StatelessWidget {
  final PostController post;
  final VoidCallback? onTap;

  const PostDetailImageDisplay({
    required this.post,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PostDetailImageButtons(
      onOpen: onTap,
      post: post,
      child: ImageOverlay(
        post: post,
        builder: (context) => Center(
          child: Hero(
            tag: post.value.hero,
            child: post.value.type == PostType.video
                ? PostDetailVideo(post: post.value)
                : PostDetailImage(post: post.value),
          ),
        ),
      ),
    );
  }
}
