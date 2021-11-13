import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class TagListActions extends StatefulWidget {
  final String tag;

  const TagListActions({required this.tag});

  @override
  State<StatefulWidget> createState() {
    return _TagListActionsState();
  }
}

class _TagListActionsState extends State<TagListActions> with LinkingMixin {
  late List<String> denylist;
  late List<Follow> follows;

  @override
  Map<ChangeNotifier, VoidCallback> get initLinks => {
        settings.denylist: updateLists,
        settings.follows: updateLists,
      };

  void updateLists() {
    setState(() {
      denylist = List.from(settings.denylist.value);
      follows = List.from(settings.follows.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tag.startsWith('e621:')) {
      return SizedBox.shrink();
    }

    bool following = follows.any((element) => element.tags == widget.tag);
    bool denied = denylist.contains(widget.tag);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CrossFade(
          showChild: !denied,
          child: IconButton(
            onPressed: () {
              if (following) {
                follows.removeWhere((element) => element.tags == widget.tag);
              } else {
                follows.add(Follow.fromString(widget.tag));
                if (denied) {
                  denylist.remove(widget.tag);
                  updateBlacklist(
                    context: context,
                    denylist: denylist,
                    immediate: true,
                  );
                }
              }
              settings.follows.value = follows;
            },
            icon: CrossFade(
              showChild: following,
              child: Icon(Icons.turned_in),
              secondChild: Icon(Icons.turned_in_not),
            ),
            tooltip: following ? 'unfollow tag' : 'follow tag',
          ),
        ),
        CrossFade(
          showChild: !following,
          child: IconButton(
            onPressed: () {
              if (denied) {
                denylist.remove(widget.tag);
              } else {
                denylist.add(widget.tag);
                if (following) {
                  follows.removeWhere((element) => element.tags == widget.tag);
                  settings.follows.value = follows;
                }
              }
              updateBlacklist(
                context: context,
                denylist: denylist,
                immediate: true,
              );
            },
            icon: CrossFade(
              showChild: denied,
              child: Icon(Icons.check),
              secondChild: Icon(Icons.block),
            ),
            tooltip: denied ? 'unblock tag' : 'block tag',
          ),
        ),
      ],
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
