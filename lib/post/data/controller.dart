import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

enum DenyListMode {
  unavailable,
  filtering,
  plain,
}

typedef PostProviderCallback = Future<List<Post>> Function(
    String search, int page, bool force)?;

class PostController extends DataController<Post>
    with SearchableController, HostableController, RefreshableController {
  late final PostProviderCallback _provider;

  Map<String, List<Post>>? deniedPosts;
  late final ValueNotifier<bool> denying;
  late final DenyListMode denyMode;
  final ValueNotifier<List<String>> allowedTags = ValueNotifier([]);
  final ValueNotifier<List<Post>> allowedPosts = ValueNotifier([]);

  List<Post>? _posts;

  @override
  late ValueNotifier<String> search;
  bool canSearch;

  late final List<Listenable> _filterNotifiers = [
    allowedTags,
    allowedPosts,
    denying,
    settings.denylist
  ];

  PostController({
    PostProviderCallback provider,
    String? search,
    bool denying = true,
    this.canSearch = true,
    this.denyMode = DenyListMode.filtering,
  }) : search = ValueNotifier(sortTags(search ?? '')) {
    _provider = provider;
    this.denying = ValueNotifier(denying);
    for (final element in _filterNotifiers) {
      element.addListener(reapplyFilter);
    }
  }

  @protected
  List<Post> filter(List<Post> items) {
    List<String> denylist = [];
    if (denying.value && denyMode != DenyListMode.unavailable) {
      denylist = settings.denylist.value
          .where((line) => !allowedTags.value.contains(line))
          .toList();
    }

    deniedPosts ??= {};
    List<Post> remaining = List.from(items);
    for (Post item in items) {
      if (allowedPosts.value.contains(item)) {
        continue;
      }
      List<String> deniers = item.getDeniers(denylist);
      for (final denier in deniers) {
        deniedPosts!.putIfAbsent(denier, () => []);
        deniedPosts![denier]!.add(item);
      }
      if (deniers.isNotEmpty && denyMode != DenyListMode.plain) {
        remaining.remove(item);
      }
    }
    return remaining;
  }

  @protected
  void reapplyFilter() {
    if (_posts != null) {
      deniedPosts = null;
      value = PagingState(
        nextPageKey: nextPageKey,
        itemList: filter(_posts!),
        error: error,
      );
    }
  }

  @override
  @protected
  Future<List<Post>> provide(int page, bool force) async {
    List<Post> nextPage;
    if (_provider != null) {
      nextPage = await _provider!(search.value, page, force);
    } else {
      nextPage = await client.posts(page, search: search.value, force: force);
    }
    _posts ??= [];
    _posts!.addAll(nextPage);
    return filter(nextPage);
  }

  @override
  Future<void> refresh({bool force = false, bool background = false}) async {
    if (!await canRefresh()) {
      return;
    }
    _posts = null;
    deniedPosts = null;
    await super.refresh(force: force, background: background);
  }

  @override
  void dispose() {
    for (final element in _filterNotifiers) {
      element.removeListener(reapplyFilter);
    }
    for (final element in [
      allowedTags,
      denying,
    ]) {
      element.dispose();
    }
    super.dispose();
  }

  @override
  void updateItem(int index, Post item) {
    assert(itemList != null && _posts != null,
        'Cannot update posts on empty post list');
    Post original = itemList![index];
    _posts![_posts!.indexOf(original)] = item;
    reapplyFilter();
  }

  bool isDenied(Post post) {
    assert(deniedPosts != null, 'Cannot check for denied on empty map');
    return deniedPosts!.values.any((element) => element.contains(post));
  }

  bool isAllowed(Post post) {
    return allowedPosts.value.contains(post);
  }

  void allow(Post post) {
    allowedPosts.value = List.from(allowedPosts.value)..add(post);
  }

  void unallow(Post post) {
    allowedPosts.value = List.from(allowedPosts.value)..remove(post);
  }

  Future<bool> fav(BuildContext context, Post post,
      {Duration? cooldown}) async {
    cooldown ??= Duration(milliseconds: 0);
    if (await client.addFavorite(post.id)) {
      // cooldown avoids interference with animation
      await Future.delayed(cooldown);
      post.isFavorited = true;
      post.favCount += 1;
      updateItem(itemList!.indexOf(post), post);
      if (settings.upvoteFavs.value) {
        Future.delayed(Duration(seconds: 1) - cooldown).then(
          (_) =>
              vote(context: context, post: post, upvote: true, replace: true),
        );
      }
      return true;
    } else {
      post.favCount -= 1;
      post.isFavorited = false;
      updateItem(itemList!.indexOf(post), post);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 1),
          content: Text('Failed to add Post #${post.id} to favorites'),
        ),
      );
      return false;
    }
  }

  Future<bool> unfav(BuildContext context, Post post) async {
    if (await client.removeFavorite(post.id)) {
      post.isFavorited = false;
      post.favCount -= 1;
      updateItem(itemList!.indexOf(post), post);
      return true;
    } else {
      post.favCount += 1;
      post.isFavorited = true;
      updateItem(itemList!.indexOf(post), post);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 1),
          content: Text('Failed to remove Post #${post.id} from favorites'),
        ),
      );
      return false;
    }
  }

  Future<void> vote({
    required BuildContext context,
    required Post post,
    required bool upvote,
    required bool replace,
  }) async {
    if (await client.votePost(post.id, upvote, replace)) {
      if (post.voteStatus == VoteStatus.unknown) {
        if (upvote) {
          post.score.total += 1;
          post.score.up += 1;
          post.voteStatus = VoteStatus.upvoted;
        } else {
          post.score.total -= 1;
          post.score.down += 1;
          post.voteStatus = VoteStatus.downvoted;
        }
      } else {
        if (upvote) {
          if (post.voteStatus == VoteStatus.upvoted) {
            post.score.total -= 1;
            post.score.down += 1;
            post.voteStatus = VoteStatus.unknown;
          } else {
            post.score.total += 2;
            post.score.up += 1;
            post.score.down -= 1;
            post.voteStatus = VoteStatus.upvoted;
          }
        } else {
          if (post.voteStatus == VoteStatus.upvoted) {
            post.score.total -= 2;
            post.score.up -= 1;
            post.score.down *= 1;
            post.voteStatus = VoteStatus.downvoted;
          } else {
            post.score.total += 1;
            post.score.up += 1;
            post.voteStatus = VoteStatus.unknown;
          }
        }
      }
      updateItem(itemList!.indexOf(post), post);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 1),
        content: Text('Failed to vote on Post #${post.id}'),
      ));
    }
  }

  Future<void> resetPost(Post post) async {
    Post reset = await client.post(post.id);
    updateItem(itemList!.indexOf(post), reset);
  }
}
