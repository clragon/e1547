import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/wiki/wiki.dart';
import 'package:flutter/material.dart';

IconData getFollowIcon(FollowType type) {
  switch (type) {
    case FollowType.update:
      return Icons.update;
    case FollowType.notify:
      return Icons.notifications_active;
    case FollowType.bookmark:
      return Icons.update_disabled;
    default:
      return Icons.warning;
  }
}

class FollowTile extends StatefulWidget {
  final Follow follow;
  final bool safe;

  FollowTile({required this.follow, required this.safe})
      : super(key: UniqueKey());

  @override
  _FollowTileState createState() => _FollowTileState();
}

class _FollowTileState extends State<FollowTile> {
  FollowStatus? status;

  void update() {
    if (widget.safe) {
      status = widget.follow.safe;
    } else {
      status = widget.follow.unsafe;
    }
  }

  @override
  void initState() {
    super.initState();
    update();
  }

  @override
  void didUpdateWidget(covariant FollowTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    update();
  }

  String getStatusText(FollowStatus? status) {
    if (status == null) {
      return '';
    }
    String text = status.unseen.toString();
    if (status.unseen == widget.follow.checkAmount) {
      text += '+';
    }
    text += ' new post';
    if (status.unseen! > 1) {
      text += 's';
    }
    return text;
  }

  Widget image() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Hero(
            tag: getPostHero(status!.latest),
            child: CachedNetworkImage(
              imageUrl: status!.thumbnail!,
              errorWidget: defaultErrorBuilder,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget info() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (widget.follow.type != FollowType.update)
              Padding(
                padding: EdgeInsets.only(right: 4),
                child: ShadowIcon(
                  getFollowIcon(widget.follow.type),
                  size: 16,
                  color: Colors.white,
                ),
              ),
            if (status!.unseen != null && status!.unseen! > 0)
              Expanded(
                child: Text(
                  getStatusText(status),
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        shadows: getTextShadows(),
                        color: Colors.white,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        Text(
          widget.follow.title,
          style: Theme.of(context).textTheme.headline6!.copyWith(
                shadows: getTextShadows(),
                color: Colors.white,
              ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          softWrap: true,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool active = status?.thumbnail != null;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          AnimatedOpacity(
            opacity: active ? 1 : 0,
            duration: defaultAnimationDuration,
            child: active ? image() : SizedBox.shrink(),
          ),
          Positioned(
            bottom: active ? -1 : null,
            right: active ? -1 : null,
            left: active ? -1 : null,
            child: SafeCrossFade(
              showChild: active,
              builder: (context) => AnimatedContainer(
                duration: defaultAnimationDuration,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: info(),
                ),
              ),
              secondChild: Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  widget.follow.title,
                  style: Theme.of(context).textTheme.headline6,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
              ),
            ),
          ),
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SearchPage(
                    tags: widget.follow.tags,
                    reversePools: (status?.unseen ?? 0) > 0,
                  ),
                ),
              ),
              onLongPress: () => wikiSheet(
                context: context,
                tag: widget.follow.tags,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FollowListTile extends StatefulWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onRename;
  final void Function(bool enabled) onChangeBookmark;
  final void Function(bool enabled) onChangeNotify;
  final Follow follow;
  final bool? safe;

  FollowListTile({
    required this.follow,
    required this.onEdit,
    required this.onDelete,
    required this.onRename,
    required this.onChangeBookmark,
    required this.onChangeNotify,
    required this.safe,
  }) : super(key: UniqueKey());

  @override
  _FollowListTileState createState() => _FollowListTileState();
}

class _FollowListTileState extends State<FollowListTile> {
  String? thumbnail;

  void update() {
    if (widget.safe!) {
      thumbnail = widget.follow.safe.thumbnail;
    } else {
      thumbnail = widget.follow.unsafe.thumbnail;
    }
  }

  @override
  void initState() {
    super.initState();
    update();
  }

  @override
  void didUpdateWidget(covariant FollowListTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    update();
  }

  Widget cardWidget(String tag) {
    return FakeCard(
      child: TagGesture(
        tag: tag,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Text(tagToTitle(tag)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget contextMenu() {
      bool notified = widget.follow.type == FollowType.notify;
      bool bookmarked = widget.follow.type == FollowType.bookmark;

      return PopupMenuButton<VoidCallback>(
        icon: ShadowIcon(
          Icons.more_vert,
          color: Colors.white,
        ),
        onSelected: (value) => value(),
        itemBuilder: (context) => [
          /*
          if (!bookmarked)
            PopupMenuTile(
              value: () => widget.onChangeNotify(!notified),
              title:
                  notified ? 'Disable notifications' : 'Enable notifications',
              icon: notified
                  ? Icons.notifications_off
                  : Icons.notifications_active,
            ),
           */
          if (!notified)
            PopupMenuTile(
              value: () => widget.onChangeBookmark(!bookmarked),
              title: bookmarked ? 'Enable updates' : 'Disable updates',
              icon: bookmarked ? Icons.update : Icons.update_disabled,
            ),
          if (widget.follow.tags.split(' ').length > 1)
            PopupMenuTile(
              value: widget.onRename,
              title: 'Rename',
              icon: Icons.label,
            ),
          PopupMenuTile(
            value: widget.onEdit,
            title: 'Edit',
            icon: Icons.edit,
          ),
          PopupMenuTile(
            value: widget.onDelete,
            title: 'Delete',
            icon: Icons.delete,
          ),
        ],
      );
    }

    String getStatusText(FollowStatus? status) {
      if (status == null) {
        return '';
      }
      String text = status.unseen.toString();
      if (status.unseen == widget.follow.checkAmount) {
        text += '+';
      }
      text += ' new post';
      if (status.unseen! > 1) {
        text += 's';
      }
      return text;
    }

    return PostPresenterTile(
      postId: widget.follow.latest,
      thumbnail: thumbnail,
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => SearchPage(tags: widget.follow.tags))),
      onLongPress: () => wikiSheet(context: context, tag: widget.follow.tags),
      child: ListTile(
        title: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            widget.follow.title,
            style: Theme.of(context).textTheme.headline6?.copyWith(
                  shadows: getTextShadows(),
                  color: Colors.white,
                ),
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              if (widget.follow.tags.split(' ').length > 1)
                Row(children: [
                  Expanded(
                    child: Wrap(
                      direction: Axis.horizontal,
                      children: widget.follow.tags
                          .split(' ')
                          .map((tag) => cardWidget(tag))
                          .toList(),
                    ),
                  ),
                ]),
              Padding(
                padding: EdgeInsets.all(4),
                child: Row(
                  children: [
                    if (widget.follow.status.unseen != null &&
                        widget.follow.status.unseen! > 0)
                      Expanded(
                        child: Text(
                          getStatusText(widget.follow.status),
                          style:
                              Theme.of(context).textTheme.bodyText1!.copyWith(
                                    shadows: getTextShadows(),
                                    color: Colors.white,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CrossFade(
              showChild: widget.follow.type != FollowType.update,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: ShadowIcon(
                  getFollowIcon(widget.follow.type),
                  color: Colors.white,
                ),
              ),
            ),
            contextMenu(),
          ],
        ),
      ),
    );
  }
}
