import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:flutter/material.dart';

class PostDetailGallery extends StatefulWidget {
  final PostProvider? provider;
  final int initialPage;

  PostDetailGallery({required this.provider, this.initialPage = 0});

  @override
  _PostDetailGalleryState createState() => _PostDetailGalleryState();
}

class _PostDetailGalleryState extends State<PostDetailGallery> {
  late int lastIndex;
  late PageController controller;

  @override
  void initState() {
    super.initState();
    lastIndex = widget.initialPage;
    controller = PageController(
        initialPage: widget.initialPage, viewportFraction: 1.000000000001);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.provider!.posts,
      builder: (context, value, child) {
        Widget pageBuilder(BuildContext context, int index) {
          if (index == widget.provider!.posts.value.length - 1) {
            widget.provider!.loadNextPage();
          }
          return PostDetail(
            post: widget.provider!.posts.value[index],
            provider: widget.provider,
            changePage: (index) => ModalRoute.of(context)!.isCurrent
                ? controller.animateToPage(index,
                    duration: defaultAnimationDuration, curve: Curves.easeInOut)
                : controller.jumpToPage(index),
          );
        }

        return PageView.builder(
          controller: controller,
          itemBuilder: pageBuilder,
          itemCount: widget.provider!.posts.value.length,
          onPageChanged: (index) {
            if (widget.provider!.posts.value.isNotEmpty) {
              Post lastPost = widget.provider!.posts.value[lastIndex];
              if (lastPost.isEditing) {
                lastPost.resetPost();
              }
            }
            lastIndex = index;
            preloadImages(
              context: context,
              index: index,
              posts: widget.provider!.posts.value,
              size: ImageSize.sample,
            );
          },
        );
      },
    );
  }
}
