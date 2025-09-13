import 'package:e1547/app/app.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class PostDetailImage extends StatelessWidget {
  const PostDetailImage({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return PostImageWidget(
      post: post,
      size: PostImageSize.sample,
      fit: BoxFit.cover,
      lowResCacheSize: context.watch<ImageCacheSize?>()?.size,
    );
  }
}

class PostDetailVideo extends StatelessWidget {
  const PostDetailVideo({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    VideoPlayer player = post.getVideo(context)!;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => player.state.playing ? player.pause() : player.play(),
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.passthrough,
        children: [
          PostVideoWidget(post: post),
          Positioned.fill(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                child: VideoButton(player: player),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PostDetailImageActions extends StatelessWidget {
  const PostDetailImageActions({
    super.key,
    required this.post,
    required this.child,
    this.onOpen,
  });

  final Post post;
  final Widget child;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final filter = context.watch<PostFilter?>();
    final denied = filter?.denies(post) ?? false;

    VoidCallback? onTap;

    bool visible = post.file != null && (!denied || post.isFavorited);

    if (visible) {
      onTap = post.type == PostType.unsupported
          ? () => launch(post.file!)
          : onOpen;
    }

    Widget playOverlay() {
      VideoPlayer? player = post.getVideo(context);
      return InkWell(
        hoverColor: Colors.transparent,
        onTap: player != null
            ? () => player.state.playing ? player.pause() : player.play()
            : onTap,
        child: child,
      );
    }

    Widget muteButton() {
      return CrossFade.builder(
        showChild: post.type == PostType.video && post.file != null,
        builder: (context) => const Card(
          elevation: 0,
          color: Colors.black12,
          child: VideoServiceVolumeControl(),
        ),
      );
    }

    Widget? openButton() {
      if (post.type != PostType.unsupported) return null;
      return Card(
        elevation: 0,
        color: Colors.black12,
        child: InkWell(
          onTap: onTap,
          child: const Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2),
                child: Icon(Icons.open_in_new, size: 16),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Text('Open'),
              ),
            ],
          ),
        ),
      );
    }

    Widget? fullscreenButton() {
      if (post.type != PostType.video || onTap == null) {
        return null;
      }
      return CrossFade.builder(
        showChild: visible,
        builder: (context) => Card(
          elevation: 0,
          color: Colors.black12,
          child: InkWell(
            onTap: onTap,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.fullscreen, size: 24, color: Colors.white),
            ),
          ),
        ),
      );
    }

    Widget? showButton() {
      if (filter == null || filter.entriesFor(post).isEmpty) {
        return null;
      }
      return Card(
        color: denied ? Colors.transparent : Colors.black12,
        elevation: 0,
        child: InkWell(
          onTap: () =>
              denied ? filter.allow(post.id) : filter.disallow(post.id),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Icon(
                    denied ? Icons.visibility : Icons.visibility_off,
                    size: 16,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(denied ? 'show' : 'hide'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.passthrough,
      children: [
        playOverlay(),
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
                ?openButton(),
                ?fullscreenButton(),
                ?showButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PostDetailImageDisplay extends StatelessWidget {
  const PostDetailImageDisplay({super.key, required this.post, this.onTap});

  final Post post;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PostDetailImageActions(
      onOpen: onTap,
      post: post,
      child: PostImageOverlay(
        post: post,
        builder: (context) => Center(
          child: Hero(
            tag: post.link,
            child: ImageCacheSizeProvider(
              size: context.watch<ImageCacheSize?>()?.size,
              child: switch (post.type) {
                PostType.video => PostDetailVideo(post: post),
                _ => PostDetailImage(post: post),
              },
            ),
          ),
        ),
      ),
    );
  }
}
