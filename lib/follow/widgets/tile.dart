import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FollowTile extends StatelessWidget {
  final Follow follow;

  const FollowTile({required this.follow});

  @override
  Widget build(BuildContext context) {
    // TODO: idiotic design, replace with database giving out pre-hosted objects
    FollowStatus? status = context.watch<FollowsService>().status(follow);
    bool active = status?.thumbnail != null;

    String getStatusText(FollowStatus? status) {
      if (status == null) {
        return '';
      }
      String text = status.unseen.toString();
      if (status.unseen == context.watch<FollowsService>().refreshAmount) {
        text += '+';
      }
      text += ' new post';
      if (status.unseen! > 1) {
        text += 's';
      }
      return text;
    }

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      child: Stack(
        fit: StackFit.passthrough,
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              AspectRatio(
                aspectRatio: 1 / 1.2,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: CrossFade.builder(
                    showChild: active,
                    secondChild: const Icon(Icons.image_not_supported_outlined),
                    builder: (context) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Hero(
                            tag: getPostLink(status!.latest!),
                            child: CachedNetworkImage(
                              imageUrl: status.thumbnail!,
                              errorWidget: defaultErrorBuilder,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        follow.name,
                        style: Theme.of(context).textTheme.headline6,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: true,
                      ),
                    ),
                    Flexible(
                      child: Row(
                        children: [
                          if (follow.type != FollowType.update)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(
                                getFollowIcon(follow.type),
                                size: 16,
                                color: dimTextColor(context, 0.7),
                              ),
                            ),
                          if ((status?.unseen ?? 0) > 0)
                            Expanded(
                              child: Text(
                                getStatusText(status),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2!
                                    .copyWith(
                                      color: dimTextColor(context, 0.7),
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
            ],
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
              onLongPress: () => tagSearchSheet(
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
    FollowsService follows = context.watch<FollowsService>();
    FollowStatus? status = follows.status(follow);

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
              follows.replace(
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
          submit: (value) {
            value = value.trim();
            Follow result = Follow(tags: value);
            if (value.isNotEmpty) {
              follows.replace(follow, result);
            } else {
              follows.remove(follow);
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
        icon: const Icon(Icons.more_vert),
        onSelected: (value) => value(),
        itemBuilder: (context) => [
          // disabled
          if (kDebugMode && !bookmarked)
            PopupMenuTile(
              value: () => follows.replace(
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
              value: () => follows.replace(
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
            value: () => follows.remove(follow),
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
      if (status.unseen == follows.refreshAmount) {
        text += '+';
      }
      text += ' new post';
      if (status.unseen! > 1) {
        text += 's';
      }
      return text;
    }

    List<Widget> subtitles = [
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
      if (status?.unseen != null && status!.unseen! > 0)
        Row(
          children: [
            Expanded(
              child: Text(
                getStatusText(status),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
    ];

    return Padding(
      padding: const EdgeInsets.all(4),
      child: ImageTile(
        hero: status?.latest != null ? getPostLink(status!.latest!) : null,
        images: [if (status?.thumbnail != null) status!.thumbnail!],
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SearchPage(tags: follow.tags),
          ),
        ),
        onLongPress: () => tagSearchSheet(context: context, tag: follow.tags),
        title: Text(follow.name),
        subtitle: subtitles.isNotEmpty
            ? Column(
                children: subtitles,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CrossFade(
              showChild: follow.type != FollowType.update,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(getFollowIcon(follow.type)),
              ),
            ),
            contextMenu(),
          ],
        ),
      ),
    );
  }
}
