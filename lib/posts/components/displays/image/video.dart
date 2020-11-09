import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/posts/post.dart';
import 'package:flutter/material.dart';
import 'package:icon_shadow/icon_shadow.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

class PostVideo extends StatefulWidget {
  final Post post;

  const PostVideo(this.post);

  @override
  _PostVideoState createState() => _PostVideoState();
}

class _PostVideoState extends State<PostVideo> {
  @override
  void initState() {
    super.initState();
    widget.post.controller.addListener(() => setState(() {}));
    if (!widget.post.controller.value.initialized) {
      widget.post.controller.initialize();
      widget.post.controller.addListener(videoWakelock);
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.post.controller.removeListener(() => setState(() {}));
    widget.post.controller.removeListener(videoWakelock);
  }

  void videoWakelock() {
    if (widget.post.controller != null) {
      widget.post.controller.value.isPlaying
          ? Wakelock.enable()
          : Wakelock.disable();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.post.controller.value.isPlaying
          ? widget.post.controller.pause()
          : widget.post.controller.play(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          widget.post.controller.value.initialized
              ? AspectRatio(
                  aspectRatio: widget.post.controller.value.aspectRatio,
                  child: VideoPlayer(widget.post.controller),
                )
              : CachedNetworkImage(
                  imageUrl: widget.post.image.value.sample['url'],
                  placeholder: (context, url) => Center(
                      child: Container(
                    height: 26,
                    width: 26,
                    child: const CircularProgressIndicator(),
                  )),
                  errorWidget: (context, url, error) =>
                      Center(child: Icon(Icons.error_outline)),
                ),
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedOpacity(
                duration: Duration(seconds: 1),
                opacity: widget.post.controller.value.isPlaying &&
                        (!widget.post.controller.value.initialized ||
                            widget.post.controller.value.isBuffering)
                    ? 1
                    : 0,
                child: Container(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(),
                ),
              ),
              AnimatedOpacity(
                duration: Duration(milliseconds: 300),
                opacity: widget.post.controller.value.isPlaying ? 0 : 1,
                child: IconShadowWidget(
                  Icon(
                    widget.post.controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    size: 54,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  shadowColor: Colors.black,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
