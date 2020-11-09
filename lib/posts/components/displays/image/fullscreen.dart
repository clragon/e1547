import 'package:e1547/interface/cross_fade.dart';
import 'package:e1547/posts/post.dart';
import 'package:flutter/material.dart';

class FullscreenButton extends StatelessWidget {
  final Post post;
  final bool Function(Post post) isVisible;
  final void Function(BuildContext context, Post post) onTap;

  const FullscreenButton(this.post, this.onTap, this.isVisible);

  @override
  Widget build(BuildContext context) {
    return CrossFade(
      showChild: post.image.value.file['url'] != null &&
          isVisible(post) &&
          post.controller != null,
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
          onTap: () => onTap(context, post),
        ),
      ),
    );
  }
}
