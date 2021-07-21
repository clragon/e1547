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
      axis: Axis.horizontal,
      child: PhotoView.customChild(
        heroAttributes: PhotoViewHeroAttributes(tag: post.hero),
        backgroundDecoration: BoxDecoration(color: Colors.transparent),
        childSize:
            Size(post.file.width.toDouble(), post.file.height.toDouble()),
        child: PostImageWidget(post: post, size: ImageSize.file),
        initialScale: PhotoViewComputedScale.contained,
        minScale: PhotoViewComputedScale.contained,
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
