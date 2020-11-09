import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/posts/post.dart';
import 'package:flutter/material.dart';

class PostImage extends StatelessWidget {
  final Post post;

  const PostImage(this.post);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: post.image.value.sample['url'],
      placeholder: (context, url) => Center(
          child: Container(
        height: 26,
        width: 26,
        child: const CircularProgressIndicator(),
      )),
      errorWidget: (context, url, error) =>
          Center(child: Icon(Icons.error_outline)),
    );
  }
}
