import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/domain/domain.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class FollowTile extends StatelessWidget {
  const FollowTile({super.key, required this.follow});

  final Follow follow;

  @override
  Widget build(BuildContext context) {
    final domain = context.watch<Domain>();
    PromptActionController? promptController = PromptActions.maybeOf(context);
    bool active = follow.latest != null && follow.thumbnail != null;

    void editTitle() {
      promptController!.show(
        context,
        ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: Theme.of(context).isDesktop ? 600 : 0,
          ),
          child: ControlledTextField(
            labelText: 'Follow title',
            actionController: promptController,
            textController: TextEditingController(text: follow.name),
            submit: (value) {
              String? title = value.trim();
              if (follow.title != value) {
                domain.follows.useUpdate().mutate(
                  FollowUpdate(id: follow.id, title: title),
                );
              }
            },
          ),
        ),
      );
    }

    void edit() {
      promptController!.show(
        context,
        EditTagPrompt(
          onSubmit: (value) {
            value = value.trim();
            if (value.isNotEmpty) {
              domain.follows.useUpdate().mutate(
                FollowUpdate(id: follow.id, tags: value),
              );
            } else {
              domain.follows.useDelete().mutate(follow.id);
            }
          },
          actionController: promptController,
          tag: follow.tags,
          title: 'Edit follow',
        ),
      );
    }

    Widget contextMenu() {
      bool notified = follow.type == FollowType.notify;
      bool bookmarked = follow.type == FollowType.bookmark;
      final update = domain.follows.useUpdate().mutate;
      final markSeen = domain.follows.useMarkSeen().mutate;
      final delete = domain.follows.useDelete().mutate;

      return PopupMenuButton<VoidCallback>(
        icon: const Dimmed(child: Icon(Icons.more_vert)),
        onSelected: (value) => value(),
        itemBuilder: (context) => [
          if ((follow.unseen ?? 0) > 0)
            PopupMenuTile(
              value: () => markSeen([follow.id]),
              title: 'Mark as read',
              icon: Icons.mark_email_read,
            ),
          if (PlatformCapabilities.hasNotifications && !bookmarked)
            PopupMenuTile(
              value: () => update(
                FollowUpdate(
                  id: follow.id,
                  type: !notified ? FollowType.notify : FollowType.update,
                ),
              ),
              title: notified
                  ? 'Disable notifications'
                  : 'Enable notifications',
              icon: notified
                  ? Icons.notifications_off
                  : Icons.notifications_active,
            ),
          if (!PlatformCapabilities.hasNotifications || !notified)
            PopupMenuTile(
              value: () => update(
                FollowUpdate(
                  id: follow.id,
                  type: !bookmarked ? FollowType.bookmark : FollowType.update,
                ),
              ),
              title: bookmarked ? 'Subscribe' : 'Bookmark',
              icon: bookmarked ? Icons.person_add : Icons.bookmark,
            ),
          if (promptController != null && follow.tags.split(' ').length > 1)
            PopupMenuTile(value: editTitle, title: 'Rename', icon: Icons.label),
          if (promptController != null)
            PopupMenuTile(value: edit, title: 'Edit', icon: Icons.edit),
          PopupMenuTile(
            value: () => delete(follow.id),
            title: 'Unfollow',
            icon: Icons.person_remove,
          ),
        ],
      );
    }

    String getStatusText() {
      int unseen = follow.unseen ?? 0;
      String text = unseen.toString();
      if (unseen >= 5) {
        text += '+';
      }
      text += ' new post';
      if (unseen > 1) {
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
                              cacheManager: context.read<BaseCacheManager>(),
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
                          builder: (context) => PostsPage(
                            query: {'tags': follow.tags},
                            orderPoolsByOldest: (follow.unseen ?? 0) == 0,
                            readerMode: poolRegex().hasMatch(follow.tags),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
            ).copyWith(bottom: 4, right: 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        follow.name,
                        style: Theme.of(context).textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: true,
                      ),
                      CrossFade(
                        showChild: follow.alias != null,
                        child: Dimmed(
                          child: Text(
                            'alias ${follow.alias}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                      CrossFade(
                        showChild:
                            follow.title != null &&
                            follow.tags.split(' ').length > 1,
                        child: Dimmed(
                          child: Text(
                            tagToTitle(follow.tags),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                      Dimmed(
                        opacity: 0.7,
                        child: Row(
                          children: [
                            CrossFade(
                              showChild: follow.type == FollowType.notify,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: follow.type.icon,
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
