import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/wiki/wiki.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FollowTile extends StatelessWidget {
  final Follow follow;

  const FollowTile({required this.follow});

  @override
  Widget build(BuildContext context) {
    FollowStatus? status = followController.status(follow);
    bool active = status?.thumbnail != null;

    String getStatusText(FollowStatus? status) {
      if (status == null) {
        return '';
      }
      String text = status.unseen.toString();
      if (status.unseen == followController.refreshAmount) {
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
              tag: getPostHero(status.latest!),
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (follow.type != FollowType.update)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: ShadowIcon(
                    getFollowIcon(follow.type),
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              if ((status.unseen ?? 0) > 0)
                Expanded(
                  child: Text(
                    getStatusText(status),
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(
                          shadows: getTextShadows(),
                          color: Colors.white,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          Text(
            follow.name,
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
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          AnimatedOpacity(
            opacity: active ? 1 : 0,
            duration: defaultAnimationDuration,
            child: active ? image(status!) : const SizedBox.shrink(),
          ),
          Positioned(
            bottom: active ? -1 : null,
            right: active ? -1 : null,
            left: active ? -1 : null,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: active
                    ? LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : null,
              ),
              child: CrossFade.builder(
                showChild: active,
                builder: (context) => info(status!),
                secondChild: Text(
                  follow.name,
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
  final Follow follow;

  const FollowListTile({required this.follow});

  @override
  Widget build(BuildContext context) {
    SheetActionController? sheetController = SheetActions.of(context);
    FollowStatus? status = followController.status(follow);

    void editAlias() {
      sheetController!.show(
        context,
        ControlledTextField(
          labelText: 'Follow alias',
          actionController: sheetController,
          textController: TextEditingController(text: follow.name),
          submit: (value) {
            String? alias = value.trim();
            if (follow.alias != value) {
              if (value.isNotEmpty) {
                alias = value;
              } else {
                alias = null;
              }
              followController.replace(
                follow,
                Follow(
                  tags: follow.tags,
                  alias: alias,
                  type: follow.type,
                  statuses: follow.statuses,
                ),
              );
            }
          },
        ),
      );
    }

    void edit() {
      sheetController!.show(
        context,
        ControlledTextWrapper(
          submit: (value) async {
            value = value.trim();
            Follow result = Follow.fromString(value);
            if (value.isNotEmpty) {
              followController.replace(follow, result);
            } else {
              followController.remove(follow);
            }
          },
          actionController: sheetController,
          textController: TextEditingController(text: follow.tags),
          builder: (context, controller, submit) => TagInput(
            controller: controller,
            textInputAction: TextInputAction.done,
            labelText: 'Edit follow',
            submit: submit,
          ),
        ),
      );
    }

    Widget contextMenu() {
      bool notified = follow.type == FollowType.notify;
      bool bookmarked = follow.type == FollowType.bookmark;

      return PopupMenuButton<VoidCallback>(
        icon: const ShadowIcon(
          Icons.more_vert,
          color: Colors.white,
        ),
        onSelected: (value) => value(),
        itemBuilder: (context) => [
          // disabled
          if (kDebugMode && !bookmarked)
            PopupMenuTile(
              value: () => followController.replace(
                follow,
                follow.copyWith(
                  type: !notified ? FollowType.notify : FollowType.update,
                ),
              ),
              title:
                  notified ? 'Disable notifications' : 'Enable notifications',
              icon: notified
                  ? Icons.notifications_off
                  : Icons.notifications_active,
            ),
          if (!notified)
            PopupMenuTile(
              value: () => followController.replace(
                follow,
                follow.copyWith(
                  type: !bookmarked ? FollowType.bookmark : FollowType.update,
                ),
              ),
              title: bookmarked ? 'Enable updates' : 'Disable updates',
              icon: bookmarked ? Icons.update : Icons.update_disabled,
            ),
          if (sheetController != null && follow.tags.split(' ').length > 1)
            PopupMenuTile(
              value: editAlias,
              title: 'Rename',
              icon: Icons.label,
            ),
          if (sheetController != null)
            PopupMenuTile(
              value: edit,
              title: 'Edit',
              icon: Icons.edit,
            ),
          PopupMenuTile(
            value: () => followController.remove(follow),
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
      if (status.unseen == followController.refreshAmount) {
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
          padding: const EdgeInsets.all(8),
          child: Text(
            follow.name,
            style: Theme.of(context).textTheme.headline6?.copyWith(
                  shadows: getTextShadows(),
                  color: Colors.white,
                ),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              if (follow.tags.split(' ').length > 1)
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        children: follow.tags
                            .split(' ')
                            .map((tag) => TagCard(tag: tag))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    if (status?.unseen != null && status!.unseen! > 0)
                      Expanded(
                        child: Text(
                          getStatusText(status),
                          style:
                              Theme.of(context).textTheme.bodyText2!.copyWith(
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
                padding: const EdgeInsets.all(8),
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
