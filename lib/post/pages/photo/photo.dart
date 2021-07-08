import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PostPhoto extends StatelessWidget {
  final Post post;

  const PostPhoto(this.post);

  @override
  Widget build(BuildContext context) {
    return PhotoViewGestureDetectorScope(
      child: PhotoView.customChild(
        heroAttributes: PhotoViewHeroAttributes(tag: getPostHero(post)),
        backgroundDecoration: BoxDecoration(
          color: Colors.transparent,
        ),
        childSize: Size(post.file.value.width.toDouble(),
            post.file.value.height.toDouble()),
        child: CachedNetworkImage(
          fadeInDuration: Duration(milliseconds: 0),
          fadeOutDuration: Duration(milliseconds: 0),
          imageUrl: post.file.value.url,
          errorWidget: defaultErrorBuilder,
          progressIndicatorBuilder: (context, url, progress) => Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: post.sample.value.url,
                  errorWidget: defaultErrorBuilder,
                  progressIndicatorBuilder: (context, url, progress) => Center(
                    child: SizedCircularProgressIndicator(
                        size:
                            min(post.file.value.width, post.file.value.height) *
                                0.2),
                  ),
                ),
              ),
              if (progress.progress != null)
                Positioned(
                  child: LinearProgressIndicator(
                    value: progress.progress,
                    minHeight:
                        min(post.file.value.width, post.file.value.height) *
                            0.01,
                    backgroundColor: Colors.transparent,
                  ),
                  top: 0,
                  right: 0,
                  left: 0,
                ),
            ],
          ),
        ),
        maxScale: PhotoViewComputedScale.covered * 6,
      ),
    );
  }
}

Widget defaultErrorBuilder(context, url, error) =>
    Center(child: Icon(Icons.warning_amber_outlined));

Widget defaultProgressIndicatorBuilder(context, url, progress) => Center(
      child: SizedCircularProgressIndicator(
        size: 26,
        value: progress.progress,
      ),
    );
