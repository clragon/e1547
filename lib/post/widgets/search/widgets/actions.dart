import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sub/flutter_sub.dart';

class TagListActions extends StatelessWidget {
  const TagListActions({super.key, required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context) {
    if (wikiMetaTags.any((prefix) => tag.startsWith(prefix))) {
      return const SizedBox.shrink();
    }
    return Consumer2<FollowsService, Client>(
      builder: (context, follows, client, child) => SubStream<Follow?>(
        create: () => follows.follow(tag).stream,
        keys: [follows, tag],
        builder: (context, snapshot) => ValueListenableBuilder(
          valueListenable: client.traits,
          builder: (context, traits, child) => AnimatedSwitcher(
            duration: defaultAnimationDuration,
            child: [ConnectionState.none, ConnectionState.waiting]
                    .contains(snapshot.connectionState)
                ? const SizedBox.shrink()
                : Builder(
                    builder: (context) {
                      Follow? follow = snapshot.data;
                      bool hasFollow = follow != null;

                      bool following = [FollowType.update, FollowType.notify]
                          .contains(follow?.type);

                      bool notifying = follow?.type == FollowType.notify;
                      bool bookmarked = follow?.type == FollowType.bookmark;
                      bool denied = traits.denylist.contains(tag);

                      VoidCallback followBookmarkToggle(FollowType type) {
                        return () {
                          if (hasFollow) {
                            if (follow.type == type) {
                              follows.removeTag(tag);
                            }
                            if (follow.type == FollowType.notify &&
                                type == FollowType.update) {
                              follows.removeTag(tag);
                            } else {
                              follows.replace(follow.copyWith(type: type));
                            }
                          } else {
                            follows.addTag(tag, type: type);
                            if (denied) {
                              client.traits.value = traits.copyWith(
                                denylist: traits.denylist..remove(tag),
                              );
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
                                ActionButton(
                                  icon: following
                                      ? const Icon(Icons.person_remove_alt_1)
                                      : const Icon(Icons.person_add_alt_1),
                                  label: following
                                      ? const Text('Unfollow')
                                      : const Text('Follow'),
                                  onTap:
                                      followBookmarkToggle(FollowType.update),
                                ),
                                CrossFade(
                                  showChild: following,
                                  child: ActionButton(
                                    icon: notifying
                                        ? const Icon(Icons.notifications_active)
                                        : const Icon(Icons.notifications_none),
                                    label: notifying
                                        ? const Text('Mute')
                                        : const Text('Notify'),
                                    onTap: () {
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
                                  ),
                                ),
                                ActionButton(
                                  icon: bookmarked
                                      ? const Icon(Icons.turned_in)
                                      : const Icon(Icons.turned_in_not),
                                  label: bookmarked
                                      ? const Text('Unbookmark')
                                      : const Text('Bookmark'),
                                  onTap:
                                      followBookmarkToggle(FollowType.bookmark),
                                ),
                              ],
                            ),
                          ),
                          CrossFade(
                            showChild: !hasFollow,
                            child: ActionButton(
                              icon: CrossFade(
                                showChild: denied,
                                secondChild: const Icon(Icons.block),
                                child: const Icon(Icons.check),
                              ),
                              label: denied
                                  ? const Text('Unblock')
                                  : const Text('Block'),
                              onTap: () {
                                if (denied) {
                                  client.traits.value = traits.copyWith(
                                      denylist: traits.denylist
                                          .whereNot((element) => element == tag)
                                          .toList());
                                } else {
                                  if (hasFollow) {
                                    follows.removeTag(tag);
                                  }
                                  client.traits.value = traits.copyWith(
                                    denylist: [...traits.denylist, tag],
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

class RemoveTagAction extends StatelessWidget {
  const RemoveTagAction({
    super.key,
    required this.controller,
    required this.tag,
  });

  final PostsController controller;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      icon: const Icon(Icons.search_off),
      label: const Text('Remove'),
      onTap: () {
        Navigator.of(context).maybePop();
        TagMap result = TagMap(controller.query);
        result['tags'] =
            (TagMap.parse(result['tags'] ?? '')..remove(tag)).toString();
        controller.query = result;
      },
    );
  }
}

class AddTagAction extends StatelessWidget {
  const AddTagAction({
    super.key,
    required this.controller,
    required this.tag,
  });

  final PostsController controller;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      icon: const Icon(Icons.zoom_in),
      label: const Text('Add'),
      onTap: () {
        Navigator.of(context).maybePop();
        TagMap result = TagMap(controller.query);
        result['tags'] =
            (TagMap.parse(result['tags'] ?? '')..add(tag)).toString();
        controller.query = result;
      },
    );
  }
}

class SubtractTagAction extends StatelessWidget {
  const SubtractTagAction({
    super.key,
    required this.controller,
    required this.tag,
  });

  final PostsController controller;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      icon: const Icon(Icons.zoom_out),
      label: const Text('Subtract'),
      onTap: () {
        Navigator.of(context).maybePop();
        // controller.search = sortTags([controller.search, '-$tag'].join(' '));
        TagMap result = TagMap(controller.query);
        result['tags'] =
            (TagMap.parse(result['tags'] ?? '')..add('-$tag')).toString();
        controller.query = result;
      },
    );
  }
}

class TagSearchActions extends StatelessWidget {
  const TagSearchActions({
    super.key,
    required this.tag,
    required this.controller,
  });

  final String tag;
  final PostsController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        if (!controller.canSearch || tag.contains(' ')) {
          return const SizedBox.shrink();
        }

        bool isSearched =
            TagMap.parse(controller.query['tags'] ?? '').containsKey(tag);

        if (isSearched) {
          return RemoveTagAction(controller: controller, tag: tag);
        } else {
          return Row(
            mainAxisSize: MainAxisSize.min,
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
