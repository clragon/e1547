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
  final Post post;
  final PostController controller;

  const PostDetailImageToggle({required this.post, required this.controller});

  @override
  State<PostDetailImageToggle> createState() => _PostDetailImageToggleState();
}

class _PostDetailImageToggleState extends State<PostDetailImageToggle> {
  bool loading = false;
  Post? replacement;

  Post get post => widget.post;
  PostController get controller => widget.controller;

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
        if (!controller.isDenied(post)) {
          controller.allow(post);
        }
        controller.updateItem(
          controller.itemList!.indexOf(post),
          post.copyWith(
            fileRaw: post.fileRaw.copyWith(url: replacement!.fileRaw.url),
            preview: post.preview.copyWith(url: replacement!.preview.url),
            sample: post.sample.copyWith(url: replacement!.sample.url),
          ),
        );
      }
    } else {
      if (controller.isAllowed(post)) {
        controller.unallow(post);
        if (replacement != null) {
          controller.updateItem(
            controller.itemList!.indexOf(post),
            post.copyWith(
              fileRaw: post.fileRaw.copyWith(url: null),
              preview: post.preview.copyWith(url: null),
              sample: post.sample.copyWith(url: null),
            ),
          );
        }
      } else {
        controller.allow(post);
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
        animation: controller,
        builder: (context, child) => CrossFade(
          showChild: post.file.url == null ||
              (!post.isFavorited &&
                  (controller.isDenied(post) || controller.isAllowed(post))),
          duration: const Duration(milliseconds: 200),
          child: Card(
            color: controller.isAllowed(post)
                ? Colors.black12
                : Colors.transparent,
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
                        controller.isAllowed(post)
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 16,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text(controller.isAllowed(post) ? 'hide' : 'show'),
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
  final Post post;
  final PostController? controller;
  final Widget child;
  final VoidCallback? onOpen;

  const PostDetailImageButtons({
    required this.post,
    required this.child,
    this.controller,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([controller, post.getVideo(context)]),
      builder: (context, child) {
        VoidCallback? onTap;

        bool visible = post.file.url != null &&
            (!(controller?.isDenied(post) ?? false) || post.isFavorited);

        if (visible) {
          onTap = post.type == PostType.unsupported
              ? () => launch(post.file.url!)
              : onOpen;
        }

        Widget fullscreenButton() {
          if (post.type == PostType.video && onTap != null) {
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
            showChild: post.type == PostType.video && post.file.url != null,
            builder: (context) => Card(
              elevation: 0,
              color: Colors.black12,
              child: VideoHandlerVolumeControl(
                videoController: post.getVideo(context)!,
              ),
            ),
          );
        }

        return Stack(
          fit: StackFit.passthrough,
          children: [
            InkWell(
              onTap: post.type == PostType.video
                  ? () => post.getVideo(context)!.value.isPlaying
                      ? post.getVideo(context)!.pause()
                      : post.getVideo(context)!.play()
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
                    if (controller != null)
                      PostDetailImageToggle(
                        post: post,
                        controller: controller!,
                      ),
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
  final Post post;
  final PostController? controller;
  final VoidCallback? onTap;

  const PostDetailImageDisplay({
    required this.post,
    required this.controller,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PostDetailImageButtons(
      onOpen: onTap,
      post: post,
      controller: controller,
      child: ImageOverlay(
        post: post,
        controller: controller,
        builder: (context) => Center(
          child: Hero(
            tag: post.hero,
            child: post.type == PostType.video
                ? PostDetailVideo(post: post)
                : PostDetailImage(post: post),
          ),
        ),
      ),
    );
  }
}
