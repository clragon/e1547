import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/wiki/wiki.dart';
import 'package:flutter/material.dart';

class FollowTile extends StatelessWidget {
  final Follow follow;
  final String host;

  FollowTile({required this.follow, required this.host});
  @override
  Widget build(BuildContext context) {
    FollowStatus? status = follow.statuses[host];
    bool active = status?.thumbnail != null;

    String getStatusText(FollowStatus? status) {
      if (status == null) {
        return '';
      }
      String text = status.unseen.toString();
      if (status.unseen == follow.checkAmount) {
        text += '+';
      }
      text += ' new post';
      if (status.unseen! > 1) {
        text += 's';
      }
      return text;
    }

    Widget image(FollowStatus status) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Hero(
              tag: getPostHero(status.latest),
              child: CachedNetworkImage(
                imageUrl: status.thumbnail!,
                errorWidget: defaultErrorBuilder,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      );
    }

    Widget info(FollowStatus status) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (follow.type != FollowType.update)
                Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: ShadowIcon(
                    getFollowIcon(follow.type),
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              if (status.unseen != null && status.unseen! > 0)
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
            follow.title,
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

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          AnimatedOpacity(
            opacity: active ? 1 : 0,
            duration: defaultAnimationDuration,
            child: active ? image(status!) : SizedBox.shrink(),
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
                  child: info(status!),
                ),
              ),
              secondChild: Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  follow.title,
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
                    tags: follow.tags,
                    reversePools: (status?.unseen ?? 0) > 0,
                  ),
                ),
              ),
              onLongPress: () => wikiSheet(
                context: context,
                tag: follow.tags,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FollowListTile extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onRename;
  final Follow follow;
  final String? host;
  final void Function(bool enabled) onChangeBookmark;
  final void Function(bool enabled) onChangeNotify;

  FollowListTile({
    required this.follow,
    required this.host,
    required this.onEdit,
    required this.onDelete,
    required this.onRename,
    required this.onChangeBookmark,
    required this.onChangeNotify,
  });

  @override
  Widget build(BuildContext context) {
    FollowStatus? status = follow.statuses[host];

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
      bool notified = follow.type == FollowType.notify;
      bool bookmarked = follow.type == FollowType.bookmark;

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
              value: () => onChangeNotify(!notified),
              title:
                  notified ? 'Disable notifications' : 'Enable notifications',
              icon: notified
                  ? Icons.notifications_off
                  : Icons.notifications_active,
            ),
           */
          if (!notified)
            PopupMenuTile(
              value: () => onChangeBookmark(!bookmarked),
              title: bookmarked ? 'Enable updates' : 'Disable updates',
              icon: bookmarked ? Icons.update : Icons.update_disabled,
            ),
          if (follow.tags.split(' ').length > 1)
            PopupMenuTile(
              value: onRename,
              title: 'Rename',
              icon: Icons.label,
            ),
          PopupMenuTile(
            value: onEdit,
            title: 'Edit',
            icon: Icons.edit,
          ),
          PopupMenuTile(
            value: onDelete,
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
      if (status.unseen == follow.checkAmount) {
        text += '+';
      }
      text += ' new post';
      if (status.unseen! > 1) {
        text += 's';
      }
      return text;
    }

    return PostPresenterTile(
      postId: status?.latest,
      thumbnail: status?.thumbnail,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SearchPage(tags: follow.tags),
        ),
      ),
      onLongPress: () => wikiSheet(context: context, tag: follow.tags),
      child: ListTile(
        title: Padding(
          padding: EdgeInsets.all(8),
          child: Text(
            follow.title,
            style: Theme.of(context).textTheme.headline6?.copyWith(
                  shadows: getTextShadows(),
                  color: Colors.white,
                ),
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              if (follow.tags.split(' ').length > 1)
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        direction: Axis.horizontal,
                        children: follow.tags
                            .split(' ')
                            .map((tag) => cardWidget(tag))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              Padding(
                padding: EdgeInsets.all(4),
                child: Row(
                  children: [
                    if (status?.unseen != null && status!.unseen! > 0)
                      Expanded(
                        child: Text(
                          getStatusText(status),
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
              showChild: follow.type != FollowType.update,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: ShadowIcon(
                  getFollowIcon(follow.type),
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
