import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/follow.dart';
import 'package:e1547/interface.dart';
import 'package:e1547/post.dart';
import 'package:e1547/tag.dart';
import 'package:e1547/wiki.dart';
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

  FollowTile({@required this.follow, @required this.safe})
      : super(key: ObjectKey(follow));

  @override
  _FollowTileState createState() => _FollowTileState();
}

class _FollowTileState extends State<FollowTile> {
  FollowStatus status;

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

  String getStatusText(FollowStatus status) {
    if (status == null) {
      return '';
    }
    String text = status.unseen.toString();
    if (status.unseen == widget.follow.checkAmount) {
      text += '+';
    }
    text += ' new post';
    if (status.unseen > 1) {
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
            tag: 'image_${status.latest}',
            child: CachedNetworkImage(
              imageUrl: status.thumbnail,
              errorWidget: (context, url, error) => Icon(Icons.error),
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
                ),
              ),
            if (status.unseen != null && status.unseen > 0)
              Expanded(
                child: Text(
                  getStatusText(status),
                  style: TextStyle(shadows: getTextShadows()),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        Text(
          widget.follow.title,
          style: Theme.of(context)
              .textTheme
              .headline6
              .copyWith(shadows: getTextShadows()),
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

    return FakeCard(
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedOpacity(
            opacity: active ? 1 : 0,
            duration: defaultAnimationDuration,
            child: active ? image() : SizedBox.shrink(),
          ),
          AnimatedPositioned(
            bottom: active ? 0 : null,
            right: active ? 0 : null,
            left: active ? 0 : null,
            child: SafeCrossFade(
              showChild: active,
              builder: (context) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Theme.of(context).cardColor.withOpacity(0.8),
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
            duration: defaultAnimationDuration,
          ),
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SearchPage(tags: widget.follow.tags),
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
  final Function onEdit;
  final Function onDelete;
  final Function onRename;
  final Function onType;
  final Follow follow;
  final bool safe;

  FollowListTile({
    @required this.follow,
    @required this.onEdit,
    @required this.onDelete,
    @required this.onRename,
    @required this.onType,
    @required this.safe,
  }) : super(key: ObjectKey(follow));

  @override
  _FollowListTileState createState() => _FollowListTileState();
}

class _FollowListTileState extends State<FollowListTile> {
  String thumbnail;

  void update() {
    if (widget.safe) {
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
  Widget build(BuildContext context) {
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

    Widget contextMenu() {
      return PopupMenuButton(
        icon: ShadowIcon(
          Icons.more_vert,
        ),
        onSelected: (value) => value(),
        itemBuilder: (context) => [
          PopupMenuTile(
            value: widget.onType,
            title: widget.follow.type == FollowType.update
                ? 'Disable updates'
                : 'Enable updates',
            icon: widget.follow.type == FollowType.update
                ? Icons.update_disabled
                : Icons.update,
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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: thumbnail != null
                    ? Opacity(
                        opacity: 0.8,
                        child: CachedNetworkImage(
                          imageUrl: thumbnail,
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                          fit: BoxFit.cover,
                        ),
                      )
                    : SizedBox.shrink(),
              ),
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          SearchPage(tags: widget.follow.tags))),
                  onLongPress: () =>
                      wikiSheet(context: context, tag: widget.follow.tags),
                  child: ListTile(
                    title: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        widget.follow.title,
                        style: thumbnail != null
                            ? TextStyle(shadows: getTextShadows())
                            : null,
                      ),
                    ),
                    subtitle: (widget.follow.tags.split(' ').length > 1)
                        ? Row(children: [
                            Expanded(
                              child: Wrap(
                                direction: Axis.horizontal,
                                children: widget.follow.tags
                                    .split(' ')
                                    .map((tag) => cardWidget(tag))
                                    .toList(),
                              ),
                            ),
                          ])
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CrossFade(
                          showChild: widget.follow.type != FollowType.update,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child:
                                ShadowIcon(getFollowIcon(widget.follow.type)),
                          ),
                        ),
                        contextMenu(),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
          Divider()
        ],
      ),
    );
  }
}
