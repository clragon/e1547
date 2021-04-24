import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/settings.dart';
import 'package:flutter/material.dart';

class TagListActions extends StatefulWidget {
  final String tag;

  TagListActions({@required this.tag});

  @override
  State<StatefulWidget> createState() {
    return _TagListActionsState();
  }
}

class _TagListActionsState extends State<TagListActions> {
  bool denied = false;
  bool following = false;
  List<String> denylist;
  List<String> follows;

  Future<void> updateLists() async {
    denylist = await db.denylist.value;
    denied = false;
    denylist.forEach((tag) {
      if (tag == widget.tag) {
        denied = true;
      }
    });
    following = false;
    follows = await db.follows.value;
    follows.forEach((tag) {
      if (tag == widget.tag) {
        following = true;
      }
    });
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
    if (widget.tag.contains(':')) {
      return SizedBox.shrink();
    }

    if (follows != null && denylist != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CrossFade(
            showChild: !denied,
            child: IconButton(
              onPressed: () {
                if (following) {
                  follows.remove(widget.tag);
                  db.follows.value = Future.value(follows);
                } else {
                  follows.add(widget.tag);
                  db.follows.value = Future.value(follows);
                  if (denied) {
                    denylist.remove(widget.tag);
                    db.denylist.value = Future.value(denylist);
                  }
                }
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
                  denylist.remove(widget.tag);
                  db.denylist.value = Future.value(denylist);
                } else {
                  denylist.add(widget.tag);
                  db.denylist.value = Future.value(denylist);
                  if (following) {
                    follows.remove(widget.tag);
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
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.turned_in_not),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.block),
            onPressed: () {},
          ),
        ],
      );
    }
  }
}

class TagSearchActions extends StatefulWidget {
  final String tag;
  final PostProvider provider;

  TagSearchActions({@required this.tag, @required this.provider});

  @override
  _TagSearchActionsState createState() => _TagSearchActionsState();
}

class _TagSearchActionsState extends State<TagSearchActions> {
  @override
  void initState() {
    super.initState();
    widget.provider.search.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.provider.canSearch || widget.tag.contains(' ')) {
      return SizedBox.shrink();
    }

    bool isSearched = widget.provider.search.value
        .split(' ')
        .any((element) => tagToName(element) == widget.tag);

    if (isSearched) {
      return IconButton(
        icon: Icon(Icons.search_off),
        tooltip: 'Remove from search',
        onPressed: () {
          Navigator.of(context).maybePop();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.provider.search.value = widget.provider.search.value
                .replaceFirst(
                    RegExp(
                        r'(?<!\S)-?' + RegExp.escape(widget.tag) + r'(?!\S)'),
                    '');
          });
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
              WidgetsBinding.instance.addPostFrameCallback((_) {
                widget.provider.search.value =
                    widget.provider.search.value + ' ${widget.tag}';
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.zoom_out),
            tooltip: 'Subtract from search',
            onPressed: () {
              Navigator.of(context).maybePop();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                widget.provider.search.value =
                    widget.provider.search.value + ' -${widget.tag}';
              });
            },
          ),
        ],
      );
    }
  }
}
