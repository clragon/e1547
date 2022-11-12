import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FollowTile extends StatelessWidget {
  const FollowTile({required this.follow});

  final Follow follow;

  @override
  Widget build(BuildContext context) {
    SheetActionController? sheetController = SheetActions.maybeOf(context);
    FollowsService follows = context.watch<FollowsService>();
    bool active = follow.latest != null && follow.thumbnail != null;

    void editTitle() {
      sheetController!.show(
        context,
        ControlledTextField(
          labelText: 'Follow title',
          actionController: sheetController,
          textController: TextEditingController(text: follow.name),
          submit: (value) {
            String? title = value.trim();
            if (follow.title != value) {
              if (value.isNotEmpty) {
                title = value;
              } else {
                title = null;
              }
              follows.replace(follow.copyWith(
                title: title,
              ));
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
            if (value.isNotEmpty) {
              follows.replace(follow.copyWith(
                tags: value,
                updated: null,
                unseen: null,
                thumbnail: null,
                latest: null,
              ));
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
        icon: Icon(
          Icons.more_vert,
          color: dimTextColor(context, 0.7),
          size: 18,
        ),
        onSelected: (value) => value(),
        itemBuilder: (context) => [
          // disabled
          if (kDebugMode && !bookmarked)
            PopupMenuTile(
              value: () => follows.replace(
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
                follow.copyWith(
                  type: !bookmarked ? FollowType.bookmark : FollowType.update,
                ),
              ),
              title: bookmarked ? 'Enable updates' : 'Disable updates',
              icon: bookmarked ? Icons.update : Icons.update_disabled,
            ),
          if (sheetController != null && follow.tags.split(' ').length > 1)
            PopupMenuTile(
              value: editTitle,
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
            title: 'Unfollow',
            icon: Icons.bookmark_border,
          ),
        ],
      );
    }

    String getStatusText() {
      int unseen = follow.unseen ?? 0;
      String text = unseen.toString();
      if (unseen >= context.watch<FollowsUpdater>().refreshAmount) {
        text += '+';
      }
      text += ' new post';
      if (follow.unseen! > 1) {
        text += 's';
      }
      return text;
    }

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            fit: StackFit.passthrough,
            clipBehavior: Clip.none,
            alignment: Alignment.center,
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
                            tag: PostLinking.getPostLink(follow.latest!),
                            child: CachedNetworkImage(
                              imageUrl: follow.thumbnail!,
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
              Positioned.fill(
                child: Material(
                  type: MaterialType.transparency,
                  child: SelectionItemOverlay<Follow>(
                    item: follow,
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SearchPage(
                            tags: follow.tags,
                            reversePools: (follow.unseen ?? 0) > 0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8)
                .copyWith(bottom: 4, right: 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        follow.name,
                        style: Theme.of(context).textTheme.headline6,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: true,
                      ),
                      CrossFade(
                        showChild: follow.alias != null,
                        child: DimSubtree(
                          child: Text(
                            'alias ${follow.alias}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                      CrossFade(
                        showChild: follow.title != null &&
                            follow.tags.split(' ').length > 1,
                        child: DimSubtree(
                          child: Text(
                            tagToTitle(follow.tags),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                      DimSubtree(
                        opacity: 0.7,
                        child: Row(
                          children: [
                            CrossFade(
                              showChild: follow.type != FollowType.update,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Icon(
                                  getFollowIcon(follow.type),
                                ),
                              ),
                            ),
                            Expanded(
                              child: CrossFade(
                                style: FadeAnimationStyle.stacked,
                                showChild: (follow.unseen ?? 0) > 0,
                                child: Text(
                                  getStatusText(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                contextMenu(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
