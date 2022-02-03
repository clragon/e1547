import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

class DrawerCounter extends StatelessWidget {
  final PostController controller;

  const DrawerCounter({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) => DrawerCounterBody(
        posts: controller.itemList,
        controller: controller,
      ),
    );
  }
}

class DrawerMultiCounter extends StatelessWidget {
  final List<PostController> controllers;

  const DrawerMultiCounter({required this.controllers});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(controllers),
      builder: (context, child) {
        List<Post>? posts;
        for (PostController controller in controllers) {
          if (controller.itemList != null) {
            posts ??= [];
            posts.addAll(controller.itemList!);
          }
        }
        return DrawerCounterBody(posts: posts);
      },
    );
  }
}

class DrawerCounterBody extends StatelessWidget {
  final int limit;
  final List<Post>? posts;
  final PostController? controller;

  const DrawerCounterBody(
      {required this.posts, this.limit = 15, this.controller});

  @override
  Widget build(BuildContext context) {
    List<Widget>? children;

    if (posts != null) {
      List<CountedTag> tags = countTagsByPosts(posts!);
      tags.sort((a, b) => b.count.compareTo(a.count));
      children = [];
      for (CountedTag tag in tags.take(limit)) {
        children.add(TagCounterCard(
          tag: tag.tag,
          count: tag.count,
          category: tag.category,
          controller: controller,
        ));
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
              header: ListTile(
                title: Text('Tags'),
                leading: Icon(Icons.tag),
              ),
              collapsed: SizedBox.shrink(),
              expanded: Column(
                children: [
                  Divider(),
                  SafeCrossFade(
                    showChild: children != null,
                    builder: (context) => CrossFade(
                      showChild: children!.isNotEmpty,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Wrap(
                                direction: Axis.horizontal,
                                children: children,
                              ),
                            )
                          ],
                        ),
                      ),
                      secondChild: Text(
                        'no tags',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context)
                              .textTheme
                              .bodyText2!
                              .color!
                              .withOpacity(0.35),
                        ),
                      ),
                    ),
                    secondChild: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: SizedCircularProgressIndicator(size: 20),
                        ),
                      ],
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
