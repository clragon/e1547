import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class TagListActions extends StatelessWidget {
  final String tag;

  const TagListActions({required this.tag});

  @override
  Widget build(BuildContext context) {
    if (wikiMetaTags.any((prefix) => tag.startsWith(prefix))) {
      return SizedBox.shrink();
    }
    return AnimatedBuilder(
      animation: Listenable.merge([settings.denylist, followController]),
      builder: (context, child) {
        bool following = followController.followsTag(tag);
        bool denied = settings.denylist.value.contains(tag);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CrossFade(
              showChild: !denied,
              child: IconButton(
                onPressed: () {
                  if (following) {
                    followController.removeTag(tag);
                  } else {
                    followController.addTag(tag);
                    if (denied) {
                      settings.denylist.value.remove(tag);
                      updateBlacklist(
                        context: context,
                        value: settings.denylist.value,
                        immediate: true,
                      );
                    }
                  }
                },
                icon: CrossFade(
                  showChild: following,
                  child: Icon(Icons.turned_in),
                  secondChild: Icon(Icons.turned_in_not),
                ),
                tooltip: following ? 'Unfollow tag' : 'Follow tag',
              ),
            ),
            CrossFade(
              showChild: !following,
              child: IconButton(
                onPressed: () {
                  if (denied) {
                    settings.denylist.value.remove(tag);
                  } else {
                    settings.denylist.value.add(tag);
                    if (following) {
                      followController.removeTag(tag);
                    }
                  }
                  updateBlacklist(
                    context: context,
                    value: settings.denylist.value,
                    immediate: true,
                  );
                },
                icon: CrossFade(
                  showChild: denied,
                  child: Icon(Icons.check),
                  secondChild: Icon(Icons.block),
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
  final PostController controller;
  final String tag;
  const RemoveTagAction({required this.controller, required this.tag});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.search_off),
      tooltip: 'Remove from search',
      onPressed: () {
        Navigator.of(context).maybePop();
        List<String> result = controller.search.value.split(' ');
        result.removeWhere((element) => tagToName(element) == tag);
        controller.search.value = sortTags(result.join(' '));
      },
    );
  }
}

class AddTagAction extends StatelessWidget {
  final PostController controller;
  final String tag;
  const AddTagAction({required this.controller, required this.tag});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.zoom_in),
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
  final PostController controller;
  final String tag;
  const SubtractTagAction({required this.controller, required this.tag});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.zoom_out),
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
  final PostController controller;

  const TagSearchActions({required this.tag, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.search,
      builder: (context, String value, child) {
        if (!controller.canSearch || tag.contains(' ')) {
          return SizedBox.shrink();
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
