import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class TagListActions extends StatelessWidget {
  const TagListActions({required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context) {
    if (wikiMetaTags.any((prefix) => tag.startsWith(prefix))) {
      return const SizedBox.shrink();
    }
    return Consumer3<FollowsService, Client, DenylistService>(
      builder: (context, follows, client, denylist, child) =>
          SubStream<Follow?>(
        create: () => follows.watchFollow(client.host, tag),
        keys: [follows, client, tag],
        builder: (context, snapshot) {
          return AnimatedSwitcher(
            duration: defaultAnimationDuration,
            child: [ConnectionState.none, ConnectionState.waiting]
                    .contains(snapshot.connectionState)
                ? const SizedBox.shrink()
                : Builder(builder: (context) {
                    Follow? follow = snapshot.data;
                    bool hasFollow = follow != null;

                    bool following = [FollowType.update, FollowType.notify]
                        .contains(follow?.type);

                    bool notifying = follow?.type == FollowType.notify;
                    bool bookmarked = follow?.type == FollowType.bookmark;
                    bool denied = denylist.denies(tag);

                    VoidCallback followBookmarkToggle(FollowType type) {
                      return () {
                        if (hasFollow) {
                          if ([FollowType.update, FollowType.bookmark]
                                  .contains(follow.type) &&
                              follow.type != type) {
                            follows.replace(follow.copyWith(type: type));
                          } else {
                            follows.removeTag(client.host, tag);
                          }
                        } else {
                          follows.addTag(client.host, tag, type: type);
                          if (denied) {
                            denylist.remove(tag);
                          }
                        }
                      };
                    }

                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CrossFade(
                          showChild: !denied,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed:
                                    followBookmarkToggle(FollowType.update),
                                icon: following
                                    ? const Icon(Icons.person_remove_alt_1)
                                    : const Icon(Icons.person_add_alt_1),
                                tooltip:
                                    following ? 'Unfollow tag' : 'Follow tag',
                              ),
                              CrossFade(
                                showChild: following,
                                child: IconButton(
                                  onPressed: () {
                                    if (notifying) {
                                      follows.replace(follow!.copyWith(
                                        type: FollowType.update,
                                      ));
                                    } else {
                                      follows.replace(follow!.copyWith(
                                        type: FollowType.notify,
                                      ));
                                    }
                                  },
                                  icon: notifying
                                      ? const Icon(Icons.notifications_active)
                                      : const Icon(Icons.notifications_none),
                                  tooltip: notifying
                                      ? 'Do not notify for tag'
                                      : 'Notify for tag',
                                ),
                              ),
                              IconButton(
                                onPressed:
                                    followBookmarkToggle(FollowType.bookmark),
                                icon: bookmarked
                                    ? const Icon(Icons.turned_in)
                                    : const Icon(Icons.turned_in_not),
                                tooltip: bookmarked
                                    ? 'Unbookmark tag'
                                    : 'Bookmark tag',
                              ),
                            ],
                          ),
                        ),
                        CrossFade(
                          showChild: !hasFollow,
                          child: IconButton(
                            onPressed: () {
                              if (denied) {
                                denylist.remove(tag);
                              } else {
                                if (hasFollow) {
                                  follows.removeTag(client.host, tag);
                                }
                                denylist.add(tag);
                              }
                            },
                            icon: CrossFade(
                              showChild: denied,
                              secondChild: const Icon(Icons.block),
                              child: const Icon(Icons.check),
                            ),
                            tooltip: denied ? 'Unblock tag' : 'Block tag',
                          ),
                        ),
                      ],
                    );
                  }),
          );
        },
      ),
    );
  }
}

class RemoveTagAction extends StatelessWidget {
  const RemoveTagAction({required this.controller, required this.tag});

  final PostsController controller;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.search_off),
      tooltip: 'Remove from search',
      onPressed: () {
        Navigator.of(context).maybePop();
        List<String> result = controller.search.value.split(' ');
        result.removeWhere((element) => element == tag);
        controller.search.value = sortTags(result.join(' '));
      },
    );
  }
}

class AddTagAction extends StatelessWidget {
  const AddTagAction({required this.controller, required this.tag});

  final PostsController controller;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.zoom_in),
      tooltip: 'Add to search',
      onPressed: () {
        Navigator.of(context).maybePop();
        controller.search.value =
            sortTags([controller.search.value, tag].join(' '));
      },
    );
  }
}

class SubtractTagAction extends StatelessWidget {
  const SubtractTagAction({required this.controller, required this.tag});

  final PostsController controller;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.zoom_out),
      tooltip: 'Subtract from search',
      onPressed: () {
        Navigator.of(context).maybePop();
        controller.search.value =
            sortTags([controller.search.value, '-$tag'].join(' '));
      },
    );
  }
}

class TagSearchActions extends StatelessWidget {
  const TagSearchActions({required this.tag, required this.controller});

  final String tag;
  final PostsController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: controller.search,
      builder: (context, value, child) {
        if (!controller.canSearch || tag.contains(' ')) {
          return const SizedBox.shrink();
        }

        bool isSearched = controller.search.value
            .split(' ')
            .any((element) => tagToRaw(element) == tag);

        if (isSearched) {
          return RemoveTagAction(controller: controller, tag: tag);
        } else {
          return Row(
            children: [
              AddTagAction(controller: controller, tag: tag),
              SubtractTagAction(controller: controller, tag: tag),
            ],
          );
        }
      },
    );
  }
}
