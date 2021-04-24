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
            Stack(
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
          ],
        ),
      ),
    );
  }
}

class DetailImageDisplay extends StatelessWidget {
  final Post post;
  final void Function() onTap;

  const DetailImageDisplay({@required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: post.showUnsafe,
      builder: (context, value, child) {
        Widget imageToggle() {
          if (!post.isDeleted) {
            return CrossFade(
              showChild: (post.file.value.url == null ||
                  !post.isVisible ||
                  post.showUnsafe.value),
              duration: Duration(milliseconds: 200),
              child: Card(
                color:
                    post.showUnsafe.value ? Colors.black12 : Colors.transparent,
                elevation: 0,
                child: InkWell(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          post.showUnsafe.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 16,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: post.showUnsafe.value
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
                      if (post.file.value.url == null) {
                        replacement = await client.post(post.id, unsafe: true);
                      } else {
                        replacement = Post.fromMap(post.raw);
                      }
                      post.file.value = replacement.file.value;
                      post.preview.value = replacement.preview.value;
                      post.sample.value = replacement.sample.value;
                      post.showUnsafe.value = !post.showUnsafe.value;
                    }
                  },
                ),
              ),
            );
          } else {
            return SizedBox.shrink();
          }
        }

        Widget fullscreenButton() {
          if (post.type == ImageType.Video) {
            return CrossFade(
              showChild: post.file.value.url != null && post.isVisible,
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
                  onTap: () => onTap(),
                ),
              ),
            );
          } else {
            return SizedBox.shrink();
          }
        }

        Widget imageOverlay() {
          return ValueListenableBuilder(
            valueListenable: post.file,
            builder: (BuildContext context, value, Widget child) {
              return Stack(
                children: <Widget>[
                  InkWell(
                    onTap: () => onTap(),
                    child: Container(
                      constraints: BoxConstraints(
                        minHeight: (MediaQuery.of(context).size.height / 2),
                      ),
                      child: Center(
                        child: Hero(
                          tag: 'image_${post.id}',
                          child: ImageOverlay(
                            post: post,
                            builder: (context) => post.type == ImageType.Video
                                ? DetailVideo(post: post)
                                : DetailImage(post: post),
                          ),
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
      },
    );
  }
}
