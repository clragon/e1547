import 'package:collection/collection.dart';
import 'package:e1547/domain/domain.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class TagListActions extends StatelessWidget {
  const TagListActions({super.key, required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context) {
    if (wikiMetaTags.any((prefix) => tag.startsWith(prefix))) {
      return const SizedBox.shrink();
    }
    return Consumer<Domain>(
      builder: (context, domain, child) => QueryBuilder(
        query: domain.follows.useGetByTags(tags: tag),
        builder: (context, followState) => ValueListenableBuilder(
          valueListenable: domain.traits,
          builder: (context, traits, child) {
            Follow? follow = followState.data;
            bool hasFollow = follow != null;

            bool following = [
              FollowType.update,
              FollowType.notify,
            ].contains(follow?.type);

            bool notifying = follow?.type == FollowType.notify;
            bool bookmarked = follow?.type == FollowType.bookmark;
            bool denied = traits.denylist.contains(tag);

            VoidCallback followBookmarkToggle(FollowType type) {
              return () {
                if (hasFollow) {
                  if (follow.type == type) {
                    domain.follows.useDelete().mutate(follow.id);
                  }
                  if (follow.type == FollowType.notify &&
                      type == FollowType.update) {
                    domain.follows.useDelete().mutate(follow.id);
                  } else {
                    domain.follows.useUpdate().mutate(
                      FollowUpdate(id: follow.id, type: type),
                    );
                  }
                } else {
                  domain.follows.useCreate().mutate(
                    FollowRequest(tags: tag, type: type),
                  );
                  if (denied) {
                    domain.traits.value = traits.copyWith(
                      denylist: traits.denylist..remove(tag),
                    );
                  }
                }
              };
            }

            return AnimatedSwitcher(
              duration: defaultAnimationDuration,
              child: Row(
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
                          onTap: followBookmarkToggle(FollowType.update),
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
                                domain.follows.useUpdate().mutate(
                                  FollowUpdate(
                                    id: follow!.id,
                                    type: FollowType.update,
                                  ),
                                );
                              } else {
                                domain.follows.useUpdate().mutate(
                                  FollowUpdate(
                                    id: follow!.id,
                                    type: FollowType.notify,
                                  ),
                                );
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
                          onTap: followBookmarkToggle(FollowType.bookmark),
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
                          domain.accounts.push(
                            traits: traits.copyWith(
                              denylist: traits.denylist
                                  .whereNot((element) => element == tag)
                                  .toList(),
                            ),
                          );
                        } else {
                          if (hasFollow) {
                            domain.follows.useDelete().mutate(follow.id);
                          }
                          domain.accounts.push(
                            traits: traits.copyWith(
                              denylist: [...traits.denylist, tag],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
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

  final PostController controller;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      icon: const Icon(Icons.search_off),
      label: const Text('Remove'),
      onTap: () {
        Navigator.of(context).maybePop();
        QueryMap result = controller.query.toQuery();
        result['tags'] = (TagMap(result['tags'])..remove(tag)).toString();
        controller.query = result;
      },
    );
  }
}

class AddTagAction extends StatelessWidget {
  const AddTagAction({super.key, required this.controller, required this.tag});

  final PostController controller;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      icon: const Icon(Icons.zoom_in),
      label: const Text('Add'),
      onTap: () {
        Navigator.of(context).maybePop();
        final result = controller.query.toQuery();
        result['tags'] = (TagMap(result['tags'])..add(tag)).toString();
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

  final PostController controller;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      icon: const Icon(Icons.zoom_out),
      label: const Text('Subtract'),
      onTap: () {
        Navigator.of(context).maybePop();
        final result = controller.query.toQuery();
        result['tags'] = (TagMap(result['tags'])..add('-$tag')).toString();
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
  final PostController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        if (!controller.canSearch || tag.contains(' ')) {
          return const SizedBox.shrink();
        }

        bool isSearched = TagMap(controller.query['tags']).containsKey(tag);

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
