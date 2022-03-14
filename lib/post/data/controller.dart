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

  Map<String, List<Post>>? _deniedPosts;
  Map<String, List<Post>>? get deniedPosts =>
      _deniedPosts != null ? Map.unmodifiable(_deniedPosts!) : null;

  late bool _denying;
  bool get denying => _denying;

  late final DenyListMode denyMode;

  List<String> _allowedTags = [];
  List<String> get allowedTags => List.unmodifiable(_allowedTags);

  List<Post> _allowedPosts = [];
  List<Post> get allowedPosts => List.unmodifiable(_allowedPosts);

  List<Post>? _posts;

  @override
  late ValueNotifier<String> search;
  bool canSearch;

  late final List<Listenable> _filterNotifiers = [settings.denylist];

  PostController({
    PostProviderCallback provider,
    String? search,
    bool denying = true,
    this.canSearch = true,
    this.denyMode = DenyListMode.filtering,
  }) : search = ValueNotifier(sortTags(search ?? '')) {
    _provider = provider;
    _denying = denying;
    for (final element in _filterNotifiers) {
      element.addListener(reapplyFilter);
    }
  }

  @protected
  List<Post> filter(List<Post> items) {
    List<String> denylist = [];
    if (denying && denyMode != DenyListMode.unavailable) {
      denylist = settings.denylist.value
          .where((line) => !_allowedTags.contains(line))
          .toList();
    }

    _deniedPosts ??= {};
    List<Post> remaining = List.from(items);
    for (Post item in items) {
      if (_allowedPosts.contains(item)) {
        continue;
      }
      List<String> deniers = item.getDeniers(denylist);
      for (final denier in deniers) {
        _deniedPosts!.putIfAbsent(denier, () => []);
        _deniedPosts![denier]!.add(item);
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
      _deniedPosts = null;
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
  Future<void> refresh({bool background = false, bool force = false}) async {
    if (!await canRefresh()) {
      return;
    }
    _posts = null;
    _deniedPosts = null;
    _allowedPosts = [];
    await super.refresh(background: background, force: force);
  }

  @override
  void dispose() {
    for (final element in _filterNotifiers) {
      element.removeListener(reapplyFilter);
    }
    super.dispose();
  }

  @protected
  assertItemOwnership(Post item) {
    assertHasItems();
    if (!itemList!.contains(item)) {
      throw StateError('Item isnt owned by this controller');
    }
  }

  @override
  void updateItem(int index, Post item, {bool force = false}) {
    assertHasItems();
    _posts![_posts!.indexOf(itemList![index])] = item;
    super.updateItem(index, item, force: force);
  }

  void setAllowedTags(List<String> value) {
    _allowedTags = List.from(value);
    reapplyFilter();
  }

  void setDenying(bool denying) {
    _denying = denying;
    reapplyFilter();
  }

  bool isDenied(Post post) {
    assertItemOwnership(post);
    return _deniedPosts!.values.any((element) => element.contains(post));
  }

  bool isAllowed(Post post) {
    assertItemOwnership(post);
    return _allowedPosts.contains(post);
  }

  void allow(Post post) {
    assertItemOwnership(post);
    _allowedPosts.add(post);
    reapplyFilter();
  }

  void unallow(Post post) {
    assertItemOwnership(post);
    _allowedPosts.remove(post);
    reapplyFilter();
  }

  Future<bool> fav(BuildContext context, Post post,
      {Duration? cooldown}) async {
    assertItemOwnership(post);
    cooldown ??= Duration(milliseconds: 0);
    if (await client.addFavorite(post.id)) {
      // cooldown avoids interference with animation
      await Future.delayed(cooldown);
      post.isFavorited = true;
      post.favCount += 1;
      updateItem(itemList!.indexOf(post), post, force: true);
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
    assertItemOwnership(post);
    if (await client.removeFavorite(post.id)) {
      post.isFavorited = false;
      post.favCount -= 1;
      updateItem(itemList!.indexOf(post), post, force: true);
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
    assertItemOwnership(post);
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
      updateItem(itemList!.indexOf(post), post, force: true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 1),
        content: Text('Failed to vote on Post #${post.id}'),
      ));
    }
  }

  Future<void> resetPost(Post post) async {
    assertItemOwnership(post);
    Post reset = await client.post(post.id, force: true);
    updateItem(itemList!.indexOf(post), reset, force: true);
  }
}
