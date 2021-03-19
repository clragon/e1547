import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/client.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/post/widgets.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
        // postInfoWidget(),
      ],
    );
  }
}

class DetailVideo extends StatefulWidget {
  final Post post;

  const DetailVideo({@required this.post});

  @override
  _DetailVideoState createState() => _DetailVideoState();
}

class _DetailVideoState extends State<DetailVideo> {
  void update() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    widget.post.controller.addListener(update);
  }

  @override
  void dispose() {
    super.dispose();
    widget.post.controller.removeListener(update);
  }

  @override
  Widget build(BuildContext context) {
    VideoPlayerValue value = widget.post.controller.value;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => value.isPlaying
          ? widget.post.controller.pause()
          : widget.post.controller.play(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SafeCrossFade(
                showChild: value.initialized,
                child: (context) => AspectRatio(
                  aspectRatio: value.aspectRatio,
                  child: VideoPlayer(widget.post.controller),
                ),
                secondChild: DetailImage(post: widget.post),
              ),
              VideoPlayButton(
                videoController: widget.post.controller,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DetailImageDisplay extends StatefulWidget {
  final Post post;
  final void Function() onTap;

  const DetailImageDisplay({@required this.post, this.onTap});

  @override
  _DetailImageDisplayState createState() => _DetailImageDisplayState();
}

class _DetailImageDisplayState extends State<DetailImageDisplay> {
  @override
  void initState() {
    super.initState();
    widget.post.showUnsafe.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    widget.post.showUnsafe.removeListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    Widget imageToggle() {
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
                  children: <Widget>[
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
                    )
                  ],
                ),
              ),
              onTap: () async {
                if (await db.customHost.value == null) {
                  await setCustomHost(context);
                }
                if (await db.customHost.value != null) {
                  Post replacement;
                  if (widget.post.file.value.url == null) {
                    replacement =
                        await client.post(widget.post.id, unsafe: true);
                  } else {
                    replacement = Post.fromMap(widget.post.raw);
                  }
                  widget.post.file.value = replacement.file.value;
                  widget.post.preview.value = replacement.preview.value;
                  widget.post.sample.value = replacement.sample.value;
                  widget.post.showUnsafe.value = !widget.post.showUnsafe.value;
                }
              },
            ),
          ),
        );
      } else {
        return Container();
      }
    }

    Widget fullscreenButton() {
      if (widget.post.type == ImageType.Video) {
        return CrossFade(
          showChild:
              widget.post.file.value.url != null && widget.post.isVisible,
          duration: Duration(milliseconds: 200),
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
              onTap: () => widget.onTap(),
            ),
          ),
        );
      } else {
        return Container();
      }
    }

    Widget imageOverlay() {
      return ValueListenableBuilder(
        valueListenable: widget.post.file,
        builder: (BuildContext context, value, Widget child) {
          return Stack(
            children: <Widget>[
              InkWell(
                onTap: () => widget.onTap(),
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: (MediaQuery.of(context).size.height / 2),
                  ),
                  child: Hero(
                    tag: 'image_${widget.post.id}',
                    child: ImageOverlay(
                      post: widget.post,
                      builder: (context) => widget.post.type == ImageType.Video
                          ? DetailVideo(post: widget.post)
                          : DetailImage(post: widget.post),
                    ),
                  ),
                ),
              ),
              Positioned(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    fullscreenButton(),
                    imageToggle(),
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

    return imageOverlay();
  }
}
