import 'package:e1547/post/post.dart';
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
    );
  }
}

class PostDetailImageDisplay extends StatelessWidget {
  const PostDetailImageDisplay({super.key, required this.post, this.onTap});

  final Post post;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Hero(
        tag: post.link,
        child: PostDetailImage(post: post),
      ),
    );
  }
}
