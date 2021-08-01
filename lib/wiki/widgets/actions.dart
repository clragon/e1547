import 'package:e1547/follow.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:e1547/tag.dart';
import 'package:flutter/material.dart';

class TagListActions extends StatefulWidget {
  final String tag;

  TagListActions({required this.tag});

  @override
  State<StatefulWidget> createState() {
    return _TagListActionsState();
  }
}

class _TagListActionsState extends State<TagListActions> {
  bool denied = false;
  bool following = false;
  List<String>? denylist;
  List<Follow>? follows;

  Future<void> updateLists() async {
    denylist = await settings.denylist.value;
    denied = denylist!.contains(widget.tag);
    follows = await settings.follows.value;
    following = follows!.contains(widget.tag);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    settings.denylist.addListener(updateLists);
    settings.follows.addListener(updateLists);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateLists();
  }

  @override
  void dispose() {
    super.dispose();
    settings.denylist.removeListener(updateLists);
    settings.follows.removeListener(updateLists);
  }

  @override
  Widget build(BuildContext context) {
    if (follows != null && denylist != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CrossFade(
            showChild: !denied,
            child: IconButton(
              onPressed: () {
                if (following) {
                  follows!.removeWhere((element) => element.tags == widget.tag);
                } else {
                  follows!.add(Follow.fromString(widget.tag));
                  if (denied) {
                    denylist!.remove(widget.tag);
                    settings.denylist.value = Future.value(denylist);
                  }
                }
                settings.follows.value = Future.value(follows);
              },
              icon: CrossFade(
                duration: Duration(milliseconds: 200),
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
                  denylist!.remove(widget.tag);
                  settings.denylist.value = Future.value(denylist);
                } else {
                  denylist!.add(widget.tag);
                  settings.denylist.value = Future.value(denylist);
                  if (following) {
                    follows!.remove(widget.tag);
                    settings.follows.value = Future.value(follows);
                  }
                }
              },
              icon: CrossFade(
                duration: Duration(milliseconds: 200),
                showChild: denied,
                child: Icon(Icons.check),
                secondChild: Icon(Icons.block),
              ),
              tooltip: denied ? 'unblock tag' : 'block tag',
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          IconButton(
            icon: Icon(Icons.turned_in_not),
            onPressed: null,
          ),
          IconButton(
            icon: Icon(Icons.block),
            onPressed: null,
          ),
        ],
      );
    }
  }
}

class TagSearchActions extends StatelessWidget {
  final String tag;
  final PostController controller;

  TagSearchActions({required this.tag, required this.controller});

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
          return IconButton(
            icon: Icon(Icons.search_off),
            tooltip: 'Remove from search',
            onPressed: () {
              Navigator.of(context).maybePop();

              controller.search.value = sortTags(
                  (controller.search.value.split(' ')
                        ..removeWhere((element) => tagToName(element) == tag))
                      .join(' '));
            },
          );
        } else {
          return Row(
            children: [
              IconButton(
                icon: Icon(Icons.zoom_in),
                tooltip: 'Add to search',
                onPressed: () {
                  Navigator.of(context).maybePop();
                  controller.search.value =
                      sortTags([controller.search.value, tag].join(' '));
                },
              ),
              IconButton(
                icon: Icon(Icons.zoom_out),
                tooltip: 'Subtract from search',
                onPressed: () {
                  Navigator.of(context).maybePop();
                  controller.search.value =
                      sortTags([controller.search.value, '-$tag'].join(' '));
                },
              ),
            ],
          );
        }
      },
    );
  }
}
