import 'package:e1547/main/components/routes.dart';
import 'package:e1547/posts/components/displays/image/image.dart';
import 'package:e1547/posts/components/displays/image/toggle.dart';
import 'package:e1547/posts/components/displays/image/video.dart';
import 'package:e1547/posts/components/gallery.dart';
import 'package:e1547/posts/post.dart';
import 'package:e1547/posts/posts_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'image/fullscreen.dart';

class ImageContainer extends StatefulWidget {
  final Post post;
  final PostProvider provider;
  final PageController controller;

  const ImageContainer(this.post, this.provider, this.controller);

  @override
  _ImageContainerState createState() => _ImageContainerState();
}

class _ImageContainerState extends State<ImageContainer> with RouteAware {
  bool keepPlaying = false;

  @override
  void initState() {
    super.initState();
    widget.post.image.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void didPushNext() {
    super.didPushNext();
    if (!keepPlaying) {
      widget.post.controller?.pause();
    } else {
      keepPlaying = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.post.image.removeListener(() => setState(() {}));
  }

  bool isVisible(Post post) {
    return (post.isFavorite.value ||
        post.showUnsafe.value ||
        !post.isBlacklisted);
  }

  void onImageTap(BuildContext context, Post post) {
    if (post.image.value.file['url'] != null) {
      if (post.image.value.file['ext'] == 'swf') {
        launch(post.image.value.file['url']);
      } else if (isVisible(widget.post)) {
        keepPlaying = true;
        Navigator.of(context).push(MaterialPageRoute<Null>(
            settings: RouteSettings(name: 'gallery'),
            builder: (context) {
              Widget gallery(List<Post> posts) {
                return ImageGallery(
                  index: posts.indexOf(widget.post),
                  posts: posts,
                  controller: widget.controller,
                );
              }

              List<Post> posts = widget.post.isEditing.value
                  ? [widget.post]
                  : (widget.provider?.items ?? [widget.post]);
              if (widget.provider != null) {
                return ValueListenableBuilder(
                    valueListenable: widget.provider.pages,
                    builder: (context, value, child) => gallery(posts));
              } else {
                return gallery(posts);
              }
            }));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        InkWell(
          onTap: () => onImageTap(context, widget.post),
          child: Container(
            constraints: BoxConstraints(
              minHeight: (MediaQuery.of(context).size.height / 2),
            ),
            child: Center(
              child: () {
                if (widget.post.isDeleted) {
                  return const Text(
                    'Post was deleted',
                    textAlign: TextAlign.center,
                  );
                }
                if (!isVisible(widget.post)) {
                  return Text(
                    'Post is blacklisted',
                    textAlign: TextAlign.center,
                  );
                }
                if (widget.post.image.value.file['url'] == null) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: const Text(
                          'Image unavailable in safe mode',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                }
                if (widget.post.image.value.file['ext'] == "swf") {
                  return Column(
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
                          onTap: () async =>
                              launch(widget.post.image.value.file['url']),
                        ),
                      )
                    ],
                  );
                }
                return Hero(
                  tag: 'image_${widget.post.id}',
                  child: widget.post.controller != null
                      ? PostVideo(widget.post)
                      : PostImage(widget.post),
                );
              }(),
            ),
          ),
        ),
        Positioned(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FullscreenButton(widget.post, onImageTap, isVisible),
              ImageToggle(widget.post, isVisible),
            ],
          ),
          bottom: 0,
          right: 5,
        )
      ],
    );
  }
}
