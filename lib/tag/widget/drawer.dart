// TODO: Reimplement this I guess

/*

import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class DrawerTagCounter extends StatelessWidget {
  const DrawerTagCounter({super.key, required this.controller});

  final PostController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) =>
          DrawerTagCounterBody(posts: controller.items, controller: controller),
    );
  }
}

class DrawerMultiTagCounter extends StatelessWidget {
  const DrawerMultiTagCounter({super.key, required this.controllers});

  final List<PostController> controllers;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(controllers),
      builder: (context, child) {
        List<Post>? posts;
        for (PostController controller in controllers) {
          if (controller.items != null) {
            posts ??= [];
            posts.addAll(controller.items!);
          }
        }
        return DrawerTagCounterBody(posts: posts);
      },
    );
  }
}

class DrawerTagCounterBody extends StatelessWidget {
  const DrawerTagCounterBody({
    super.key,
    required this.posts,
    this.limit = 15,
    this.controller,
  });

  final int limit;
  final List<Post>? posts;
  final PostController? controller;

  @override
  Widget build(BuildContext context) {
    List<Widget>? children;

    if (posts != null) {
      List<CountedTag> tags = countTagsByPosts(posts!);
      tags.sort((a, b) => b.count.compareTo(a.count));
      children = [];
      for (CountedTag tag in tags.take(limit)) {
        children.add(
          TagCounterCard(
            tag: tag.tag,
            count: tag.count,
            category: tag.category,
          ),
        );
      }
    }

    return Column(
      children: [
        ExpandableNotifier(
          initialExpanded: true,
          child: ExpandableTheme(
            data: ExpandableThemeData(
              headerAlignment: ExpandablePanelHeaderAlignment.center,
              iconColor: Theme.of(context).iconTheme.color,
            ),
            child: ExpandablePanel(
              header: const ListTile(
                title: Text('Tags'),
                leading: Icon(Icons.tag),
              ),
              collapsed: const SizedBox.shrink(),
              expanded: Column(
                children: [
                  const Divider(),
                  CrossFade.builder(
                    showChild: children != null,
                    builder: (context) => CrossFade(
                      showChild: children!.isNotEmpty,
                      secondChild: Text(
                        'no tags',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: dimTextColor(context),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [Expanded(child: Wrap(children: children))],
                        ),
                      ),
                    ),
                    secondChild: CrossFade(
                      showChild: controller?.error != null,
                      secondChild: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: SizedCircularProgressIndicator(size: 24),
                          ),
                        ],
                      ),
                      child: const Dimmed(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.warning_amber, size: 12),
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                'failed to load tags',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}


*/
