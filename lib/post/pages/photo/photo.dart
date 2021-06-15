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
    return PhotoViewGestureDetectorScope(
        axis: Axis.horizontal,
        child: PhotoView.customChild(
          heroAttributes:
              PhotoViewHeroAttributes(tag: getPostHero(widget.post)),
          backgroundDecoration: BoxDecoration(
            color: Colors.transparent,
          ),
          childSize: Size(widget.post.file.value.width.toDouble(),
              widget.post.file.value.height.toDouble()),
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
              return Image(
                image: provider,
                fit: BoxFit.contain,
              );
            },
            progressIndicatorBuilder: (context, url, progress) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: widget.post.sample.value.url,
                      imageBuilder: (context, provider) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() {
                            if (loadingState == LoadingState.none) {
                              loadingState = LoadingState.sample;
                            }
                          });
                        });
                        return Image(
                          image: provider,
                          fit: BoxFit.contain,
                        );
                      },
                      errorWidget: (context, url, error) =>
                          Center(child: Icon(Icons.error_outline)),
                      progressIndicatorBuilder: (context, url, progress) {
                        return Center(
                          child: Container(
                            height:
                                widget.post.file.value.height.toDouble() * 0.07,
                            width:
                                widget.post.file.value.height.toDouble() * 0.07,
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: CircularProgressIndicator(
                                strokeWidth:
                                    widget.post.file.value.height.toDouble() *
                                        0.005,
                                value: progress.progress,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    child: CrossFade(
                      child: LinearProgressIndicator(
                        value: progress.progress,
                        minHeight:
                            widget.post.file.value.height.toDouble() * 0.01,
                        backgroundColor: Colors.transparent,
                      ),
                      showChild: loadingState == LoadingState.sample,
                    ),
                    top: 0,
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
        ));
  }
}

enum LoadingState {
  none,
  sample,
  full,
}
