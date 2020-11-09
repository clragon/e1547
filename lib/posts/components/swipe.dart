import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/posts/components/detail.dart';
import 'package:e1547/posts/post.dart';
import 'package:e1547/posts/posts_page.dart';
import 'package:flutter/material.dart';

class PostSwipe extends StatelessWidget {
  final PostProvider provider;
  final int startingIndex;

  PostSwipe({@required this.provider, this.startingIndex = 0});

  @override
  Widget build(BuildContext context) {
    int lastIndex = startingIndex;
    PageController controller = PageController(
        initialPage: startingIndex, viewportFraction: 1.000000000001);

    Widget _pageBuilder(BuildContext context, int index) {
      if (index == provider.items.length - 1) {
        provider.loadNextPage();
      }
      return index < provider.items.length
          ? PostWidget(
              post: provider.items[index],
              provider: provider,
              controller: controller,
            )
          : null;
    }

    return ValueListenableBuilder(
      valueListenable: provider.pages,
      builder: (context, value, child) {
        return PageView.builder(
          controller: controller,
          itemBuilder: _pageBuilder,
          onPageChanged: (index) {
            int precache = 2;
            for (int i = -precache - 1; i < precache; i++) {
              int target = index + 1 + i;
              if (target > 0 && target < provider.items.length) {
                if (provider.items[target].image.value.sample['url'] != null) {
                  precacheImage(
                    CachedNetworkImageProvider(
                        provider.items[target].image.value.sample['url']),
                    context,
                  );
                }
              }
            }

            if (provider.items.length != 0) {
              if (provider.items[lastIndex].isEditing.value) {
                resetPost(provider.items[lastIndex]);
              }
            }
            lastIndex = index;
          },
        );
      },
    );
  }
}
