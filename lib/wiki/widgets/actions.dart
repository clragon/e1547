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
    denylist = await db.denylist.value;
    denied = denylist!.contains(widget.tag);
    follows = await db.follows.value;
    following = follows!.contains(widget.tag);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    db.denylist.addListener(updateLists);
    db.follows.addListener(updateLists);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateLists();
  }

  @override
  void dispose() {
    super.dispose();
    db.denylist.removeListener(updateLists);
    db.follows.removeListener(updateLists);
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
                    db.denylist.value = Future.value(denylist);
                  }
                }
                db.follows.value = Future.value(follows);
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
                  db.denylist.value = Future.value(denylist);
                } else {
                  denylist!.add(widget.tag);
                  db.denylist.value = Future.value(denylist);
                  if (following) {
                    follows!.remove(widget.tag);
                    db.follows.value = Future.value(follows);
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
  final PostProvider provider;

  TagSearchActions({required this.tag, required this.provider});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: provider.search,
      builder: (context, String value, child) {
        if (!provider.canSearch || tag.contains(' ')) {
          return SizedBox.shrink();
        }

        bool isSearched = provider.search.value
            .split(' ')
            .any((element) => tagToName(element) == tag);

        if (isSearched) {
          return IconButton(
            icon: Icon(Icons.search_off),
            tooltip: 'Remove from search',
            onPressed: () {
              Navigator.of(context).maybePop();

              provider.search.value = sortTags((provider.search.value.split(' ')
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
                  provider.search.value =
                      sortTags([provider.search.value, tag].join(' '));
                },
              ),
              IconButton(
                icon: Icon(Icons.zoom_out),
                tooltip: 'Subtract from search',
                onPressed: () {
                  Navigator.of(context).maybePop();
                  provider.search.value =
                      sortTags([provider.search.value, '-$tag'].join(' '));
                },
              ),
            ],
          );
        }
      },
    );
  }
}
