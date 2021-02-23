import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PostPhoto extends StatefulWidget {
  final Post post;

  PostPhoto(this.post);

  @override
  _PostPhotoState createState() => _PostPhotoState();
}

class _PostPhotoState extends State<PostPhoto> {
  LoadingState loadingState = LoadingState.none;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedOpacity(
          duration: Duration(milliseconds: 200),
          opacity: loadingState == LoadingState.none ? 1 : 0,
          child: Container(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(),
          ),
        ),
        PhotoViewGestureDetectorScope(
            axis: Axis.horizontal,
            child: PhotoView.customChild(
              heroAttributes:
                  PhotoViewHeroAttributes(tag: 'image_${widget.post.id}'),
              backgroundDecoration: BoxDecoration(
                color: Colors.transparent,
              ),
              childSize: () {
                double width;
                double height;
                switch (loadingState) {
                  case LoadingState.none:
                  // this is unecessary, because no image is shown
                  // disabled to prevent possible size flickering
                  /*
                    width = MediaQuery.of(context).size.width;
                    height = MediaQuery.of(context).size.height;
                    break;
                    */
                  case LoadingState.sample:
                    width = widget.post.sample.value.width.toDouble();
                    height = widget.post.sample.value.height.toDouble();
                    break;
                  case LoadingState.full:
                    width = widget.post.file.value.width.toDouble();
                    height = widget.post.file.value.height.toDouble();
                    break;
                }
                return Size(width, height);
              }(),
              child: CachedNetworkImage(
                fadeInDuration: Duration(milliseconds: 0),
                fadeOutDuration: Duration(milliseconds: 0),
                imageUrl: widget.post.file.value.url,
                imageBuilder: (context, provider) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      loadingState = LoadingState.full;
                    });
                  });
                  return Image(image: provider);
                },
                placeholder: (context, chunk) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      CachedNetworkImage(
                        imageUrl: widget.post.sample.value.url,
                        imageBuilder: (context, provider) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              if (loadingState == LoadingState.none) {
                                loadingState = LoadingState.sample;
                              }
                            });
                          });
                          return Image(image: provider);
                        },
                        errorWidget: (context, url, error) =>
                            Center(child: Icon(Icons.error_outline)),
                      ),
                      Positioned(
                        child: CrossFade(
                          child: LinearProgressIndicator(
                            minHeight:
                                widget.post.sample.value.height.toDouble() /
                                    100,
                            backgroundColor: Colors.transparent,
                          ),
                          showChild: loadingState == LoadingState.sample,
                        ),
                        bottom: 0,
                        right: 0,
                        left: 0,
                      ),
                    ],
                  );
                },
                errorWidget: (context, url, error) =>
                    Center(child: Icon(Icons.error_outline)),
              ),
              initialScale: PhotoViewComputedScale.contained,
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 6,
            )),
      ],
    );
  }
}

enum LoadingState {
  none,
  sample,
  full,
}
