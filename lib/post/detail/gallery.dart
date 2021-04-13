import 'package:e1547/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class PostDetailGallery extends StatefulWidget {
  final PostProvider provider;
  final int initialPage;

  PostDetailGallery({@required this.provider, this.initialPage = 0});

  @override
  _PostDetailGalleryState createState() => _PostDetailGalleryState();
}

class _PostDetailGalleryState extends State<PostDetailGallery> {
  int lastIndex;
  PageController controller;

  @override
  void initState() {
    super.initState();
    lastIndex = widget.initialPage;
    controller = PageController(
        initialPage: widget.initialPage, viewportFraction: 1.000000000001);
  }

  @override
  Widget build(BuildContext context) {
    Widget _pageBuilder(BuildContext context, int index) {
      if (index == widget.provider.posts.value.length - 1) {
        widget.provider.loadNextPage();
      }
      return index < widget.provider.posts.value.length
          ? PostDetail(
              post: widget.provider.posts.value[index],
              provider: widget.provider,
              controller: controller,
            )
          : null;
    }

    return ValueListenableBuilder(
      valueListenable: widget.provider.pages,
      builder: (context, value, child) {
        return PageView.builder(
          controller: controller,
          itemBuilder: _pageBuilder,
          onPageChanged: (index) {
            int reach = 2;
            for (int i = -(reach + 1); i < reach; i++) {
              int target = index + 1 + i;
              if (0 < target && target < widget.provider.posts.value.length) {
                String url =
                    widget.provider.posts.value[target].sample.value.url;
                if (url != null) {
                  DefaultCacheManager().downloadFile(url);
                }
              }
            }
            if (widget.provider.posts.value.length != 0) {
              if (widget.provider.posts.value[lastIndex].isEditing.value) {
                widget.provider.posts.value[lastIndex].resetPost();
              }
            }
            lastIndex = index;
          },
        );
      },
    );
  }
}
