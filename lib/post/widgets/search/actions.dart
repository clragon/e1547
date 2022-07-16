import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TagListActions extends StatelessWidget {
  final String tag;

  const TagListActions({required this.tag});

  @override
  Widget build(BuildContext context) {
    if (wikiMetaTags.any((prefix) => tag.startsWith(prefix))) {
      return const SizedBox.shrink();
    }
    return Consumer2<FollowsService, DenylistService>(
      builder: (context, follows, denylist, child) {
        bool following = follows.follows(tag);
        bool denied = denylist.denies(tag);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CrossFade(
              showChild: !denied,
              child: IconButton(
                onPressed: () async {
                  if (following) {
                    follows.removeTag(tag);
                  } else {
                    follows.addTag(tag);
                    if (denied) {
                      await denylist.remove(tag);
                    }
                  }
                },
                icon: CrossFade(
                  showChild: following,
                  secondChild: const Icon(Icons.turned_in_not),
                  child: const Icon(Icons.turned_in),
                ),
                tooltip: following ? 'Unfollow tag' : 'Follow tag',
              ),
            ),
            CrossFade(
              showChild: !following,
              child: IconButton(
                onPressed: () async {
                  if (denied) {
                    await denylist.remove(tag);
                  } else {
                    if (following) {
                      follows.removeTag(tag);
                    }
                    await denylist.add(tag);
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
        );
      },
    );
  }
}

class RemoveTagAction extends StatelessWidget {
  final PostsController controller;
  final String tag;

  const RemoveTagAction({required this.controller, required this.tag});

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
  final PostsController controller;
  final String tag;

  const AddTagAction({required this.controller, required this.tag});

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
  final PostsController controller;
  final String tag;

  const SubtractTagAction({required this.controller, required this.tag});

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
  final String tag;
  final PostsController controller;

  const TagSearchActions({required this.tag, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.search,
      builder: (context, String value, child) {
        if (!controller.canSearch || tag.contains(' ')) {
          return const SizedBox.shrink();
        }

        bool isSearched = controller.search.value
            .split(' ')
            .any((element) => tagToName(element) == tag);

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
