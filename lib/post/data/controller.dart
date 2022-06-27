import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
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

  Map<String, List<Post>>? _previousDeniedPosts;
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

  late final List<Listenable> _filterNotifiers = [denylistController];

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

  @override
  void appendPage(List<Post> newItems, int? nextPageKey) {
    _posts ??= [];
    _posts!.addAll(newItems);
    List<Post> itemList = (value.itemList ?? []) + newItems;
    value = PagingState(
      itemList: filter(itemList),
      nextPageKey: nextPageKey,
    );
  }

  @protected
  List<Post> filter(List<Post> items) {
    List<String> denylist = [];
    if (denying && denyMode != DenyListMode.unavailable) {
      denylist =
          denylistController.items.whereNot(_allowedTags.contains).toList();
    }

    _deniedPosts ??= {};
    List<Post> result = {for (final p in items) p.id: p}.values.toList();

    result.removeWhere((item) {
      if (_allowedPosts.contains(item)) {
        return false;
      }
      List<String> deniers = item.getDeniers(denylist);
      for (final denier in deniers) {
        _deniedPosts!.putIfAbsent(denier, () => []);
        _deniedPosts![denier]!.add(item);
      }
      if (deniers.isNotEmpty && denyMode != DenyListMode.plain) {
        return true;
      }
      return false;
    });

    _previousDeniedPosts = null;
    return result;
  }

  @protected
  void reapplyFilter() {
    if (_posts != null) {
      _previousDeniedPosts = _deniedPosts;
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
    if (_provider != null) {
      return _provider!(search.value, page, force);
    } else {
      return client.posts(page, search: search.value, force: force);
    }
  }

  @override
  Future<void> refresh({bool background = false, bool force = false}) async {
    if (!await canRefresh()) {
      return;
    }
    _posts = null;
    _previousDeniedPosts = _deniedPosts;
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

  void _assertItemOwnership(Post item) {
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
    _assertItemOwnership(post);
    return (_deniedPosts ?? _previousDeniedPosts!)
        .values
        .any((e) => e.contains(post));
  }

  bool isAllowed(Post post) {
    _assertItemOwnership(post);
    return _allowedPosts.contains(post);
  }

  void allow(Post post) {
    _assertItemOwnership(post);
    _allowedPosts.add(post);
    reapplyFilter();
  }

  void unallow(Post post) {
    _assertItemOwnership(post);
    _allowedPosts.remove(post);
    reapplyFilter();
  }

  Future<bool> fav(BuildContext context, Post post,
      {Duration? cooldown}) async {
    _assertItemOwnership(post);
    cooldown ??= const Duration();
    if (await client.addFavorite(post.id)) {
      // cooldown avoids interference with animation
      await Future.delayed(cooldown);
      updateItem(
        itemList!.indexOf(post),
        post.copyWith(
          isFavorited: true,
          favCount: post.favCount + 1,
        ),
        force: true,
      );
      if (settings.upvoteFavs.value) {
        Future.delayed(const Duration(seconds: 1) - cooldown).then(
          (_) =>
              vote(context: context, post: post, upvote: true, replace: true),
        );
      }
      return true;
    } else {
      updateItem(
        itemList!.indexOf(post),
        post.copyWith(
          isFavorited: false,
          favCount: post.favCount - 1,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 1),
          content: Text('Failed to add Post #${post.id} to favorites'),
        ),
      );
      return false;
    }
  }

  Future<bool> unfav(BuildContext context, Post post) async {
    _assertItemOwnership(post);
    if (await client.removeFavorite(post.id)) {
      updateItem(
        itemList!.indexOf(post),
        post.copyWith(
          isFavorited: false,
          favCount: post.favCount - 1,
        ),
        force: true,
      );
      return true;
    } else {
      updateItem(
        itemList!.indexOf(post),
        post.copyWith(
          isFavorited: true,
          favCount: post.favCount + 1,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 1),
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
    _assertItemOwnership(post);
    if (await client.votePost(post.id, upvote, replace)) {
      Post updated = post.copyWith();
      if (post.voteStatus == VoteStatus.unknown) {
        if (upvote) {
          updated = updated.copyWith(
            score: post.score.copyWith(
              total: post.score.total + 1,
              up: post.score.up + 1,
            ),
            voteStatus: VoteStatus.upvoted,
          );
        } else {
          updated = updated.copyWith(
            score: post.score.copyWith(
              total: post.score.total - 1,
              down: post.score.down + 1,
            ),
            voteStatus: VoteStatus.downvoted,
          );
        }
      } else {
        if (upvote) {
          if (post.voteStatus == VoteStatus.upvoted) {
            updated = updated.copyWith(
              score: post.score.copyWith(
                total: post.score.total - 1,
                down: post.score.down + 1,
              ),
              voteStatus: VoteStatus.unknown,
            );
          } else {
            updated = updated.copyWith(
              score: post.score.copyWith(
                total: post.score.total + 2,
                up: post.score.up + 1,
                down: post.score.down - 1,
              ),
              voteStatus: VoteStatus.upvoted,
            );
          }
        } else {
          if (post.voteStatus == VoteStatus.upvoted) {
            updated = updated.copyWith(
              score: post.score.copyWith(
                total: post.score.total - 2,
                up: post.score.up - 1,
                down: post.score.down + 1,
              ),
              voteStatus: VoteStatus.downvoted,
            );
          } else {
            updated = updated.copyWith(
              score: post.score.copyWith(
                total: post.score.total + 1,
                up: post.score.up + 1,
              ),
              voteStatus: VoteStatus.unknown,
            );
          }
        }
      }
      updateItem(itemList!.indexOf(post), updated, force: true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(seconds: 1),
        content: Text('Failed to vote on Post #${post.id}'),
      ));
    }
  }

  Future<void> resetPost(Post post) async {
    _assertItemOwnership(post);
    Post reset = await client.post(post.id, force: true);
    updateItem(itemList!.indexOf(post), reset, force: true);
  }
}
