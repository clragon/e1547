import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PostDetailGallery extends StatefulWidget {
  final PostController controller;
  final int initialPage;

  const PostDetailGallery({required this.controller, this.initialPage = 0});

  @override
  _PostDetailGalleryState createState() => _PostDetailGalleryState();
}

class _PostDetailGalleryState extends State<PostDetailGallery> {
  late int lastIndex = widget.initialPage;
  late PageController pageController =
      PageController(initialPage: widget.initialPage);

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PagedPageView(
      addAutomaticKeepAlives: false,
      builderDelegate: PagedChildBuilderDelegate<Post>(
        itemBuilder: (context, post, index) => PostDetail(
          post: post,
          controller: widget.controller,
          onPageChanged: (index) => ModalRoute.of(context)!.isCurrent
              ? pageController.animateToPage(index,
                  duration: defaultAnimationDuration, curve: Curves.easeInOut)
              : pageController.jumpToPage(index),
        ),
        firstPageProgressIndicatorBuilder: (context) => Material(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedCircularProgressIndicator(size: 28),
              Padding(
                padding: EdgeInsets.all(20),
                child: Text('Loading posts'),
              ),
            ],
          ),
        ),
        newPageProgressIndicatorBuilder: (context) => Material(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedCircularProgressIndicator(size: 28),
              Padding(
                padding: EdgeInsets.all(20),
                child: Text('Loading posts'),
              ),
            ],
          ),
        ),
        noItemsFoundIndicatorBuilder: (context) => IconMessage(
          icon: Icon(Icons.clear),
          title: Text('No posts'),
        ),
        firstPageErrorIndicatorBuilder: (context) => IconMessage(
          icon: Icon(Icons.warning_amber_outlined),
          title: Text('Failed to load posts'),
          action: PagedChildBuilderRetryButton(widget.controller),
        ),
        newPageErrorIndicatorBuilder: (context) => IconMessage(
          direction: Axis.horizontal,
          icon: Icon(Icons.warning_amber_outlined),
          title: Text('Failed to load posts'),
          action: PagedChildBuilderRetryButton(widget.controller),
        ),
      ),
      pagingController: widget.controller,
      pageController: pageController,
      onPageChanged: (index) {
        if (widget.controller.itemList!.isNotEmpty) {
          Post lastPost = widget.controller.itemList![lastIndex];
          if (lastPost.isEditing) {
            lastPost.resetPost();
          }
        }
        lastIndex = index;
        preloadImages(
          context: context,
          index: index,
          posts: widget.controller.itemList!,
          size: ImageSize.sample,
        );
      },
    );
  }
}
