import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class TagListActions extends StatelessWidget {
  const TagListActions({required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context) {
    if (wikiMetaTags.any((prefix) => tag.startsWith(prefix))) {
      return const SizedBox.shrink();
    }
    return Consumer3<FollowsService, Client, DenylistService>(
      builder: (context, follows, client, denylist, child) => SubStream<bool>(
        create: () => follows.watchFollows(client.host, tag),
        keys: [follows, client, tag],
        builder: (context, snapshot) {
          bool? following = snapshot.data;
          bool denied = denylist.denies(tag);
          return AnimatedSwitcher(
            duration: defaultAnimationDuration,
            child: following == null
                ? const SizedBox.shrink()
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CrossFade(
                        showChild: !denied,
                        child: IconButton(
                          onPressed: () {
                            if (following) {
                              follows.removeTag(client.host, tag);
                            } else {
                              follows.addTag(client.host, tag);
                              if (denied) {
                                denylist.remove(tag);
                              }
                            }
                          },
                          icon: CrossFade(
                            showChild: following,
                            secondChild: const Icon(Icons.person_add),
                            child: const Icon(Icons.person_remove),
                          ),
                          tooltip: following ? 'Unfollow tag' : 'Follow tag',
                        ),
                      ),
                      CrossFade(
                        showChild: !following,
                        child: IconButton(
                          onPressed: () {
                            if (denied) {
                              denylist.remove(tag);
                            } else {
                              if (following) {
                                follows.removeTag(client.host, tag);
                              }
                              denylist.add(tag);
                            }
                          },
                          icon: CrossFade(
                            showChild: denied,
                            secondChild: const Icon(Icons.block),
                            child: const Icon(Icons.check),
                          ),
                          tooltip: denied ? 'Unblock tag' : 'Block tag',
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class RemoveTagAction extends StatelessWidget {
  const RemoveTagAction({required this.controller, required this.tag});

  final PostsController controller;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.search_off),
      tooltip: 'Remove from search',
      onPressed: () {
        Navigator.of(context).maybePop();
        List<String> result = controller.search.value.split(' ');
        result.removeWhere((element) => element == tag);
        controller.search.value = sortTags(result.join(' '));
      },
    );
  }
}

class AddTagAction extends StatelessWidget {
  const AddTagAction({required this.controller, required this.tag});

  final PostsController controller;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.zoom_in),
      tooltip: 'Add to search',
      onPressed: () {
        Navigator.of(context).maybePop();
        controller.search.value =
            sortTags([controller.search.value, tag].join(' '));
      },
    );
  }
}

class SubtractTagAction extends StatelessWidget {
  const SubtractTagAction({required this.controller, required this.tag});

  final PostsController controller;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.zoom_out),
      tooltip: 'Subtract from search',
      onPressed: () {
        Navigator.of(context).maybePop();
        controller.search.value =
            sortTags([controller.search.value, '-$tag'].join(' '));
      },
    );
  }
}

class TagSearchActions extends StatelessWidget {
  const TagSearchActions({required this.tag, required this.controller});

  final String tag;
  final PostsController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: controller.search,
      builder: (context, value, child) {
        if (!controller.canSearch || tag.contains(' ')) {
          return const SizedBox.shrink();
        }

        bool isSearched = controller.search.value
            .split(' ')
            .any((element) => tagToRaw(element) == tag);

        if (isSearched) {
          return RemoveTagAction(controller: controller, tag: tag);
        } else {
          return Row(
            children: [
              AddTagAction(controller: controller, tag: tag),
              SubtractTagAction(controller: controller, tag: tag),
            ],
          );
        }
      },
    );
  }
}
