import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

class DrawerTagCounter extends StatelessWidget {
  const DrawerTagCounter({required this.controller});

  final PostsController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) => DrawerTagCounterBody(
        posts: controller.itemList,
      ),
    );
  }
}

class DrawerMultiTagCounter extends StatelessWidget {
  const DrawerMultiTagCounter({required this.controllers});

  final List<PostsController> controllers;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(controllers),
      builder: (context, child) {
        List<Post>? posts;
        for (PostsController controller in controllers) {
          if (controller.itemList != null) {
            posts ??= [];
            posts.addAll(controller.itemList!);
          }
        }
        return DrawerTagCounterBody(posts: posts);
      },
    );
  }
}

class DrawerTagCounterBody extends StatelessWidget {
  const DrawerTagCounterBody({
    required this.posts,
    this.limit = 15,
    this.controller,
  });

  final int limit;
  final List<Post>? posts;
  final PostsController? controller;

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
                            horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Wrap(
                                children: children,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    secondChild: CrossFade(
                      showChild: controller?.error != null,
                      secondChild: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: SizedCircularProgressIndicator(size: 24),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          'failed to load tags',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: dimTextColor(context),
                          ),
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
