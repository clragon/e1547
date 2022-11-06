import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class PostsController extends DataController<Post>
    with SearchableController, FilterableController, RefreshableController {
  PostsController({
    required this.client,
    required this.denylist,
    PostProviderCallback provider,
    String? search,
    bool denying = true,
    this.canSearch = true,
    this.denyMode = DenyListMode.filtering,
  })  : _provider = provider,
        _denying = denying,
        search = ValueNotifier(sortTags(search ?? '')) {
    _filterNotifiers.forEach((e) => e.addListener(refilter));
  }

  factory PostsController.single({
    required int id,
    required Client client,
    required DenylistService denylist,
    DenyListMode denyMode = DenyListMode.plain,
  }) {
    late PostsController controller;
    controller = PostsController(
      client: client,
      denylist: denylist,
      provider: (search, page, force) async => page == controller.firstPageKey
          ? [await client.post(id, force: force)]
          : [],
      canSearch: false,
      denyMode: denyMode,
    );
    return controller;
  }

  final Client client;
  final DenylistService denylist;

  final PostProviderCallback _provider;

  Map<Post, List<String>>? _previousDeniedPosts;
  Map<Post, List<String>>? _deniedPosts;
  Map<Post, List<String>>? get deniedPosts => _deniedPosts.maybeUnmodifiable();

  bool _denying;
  bool get denying => _denying;
  set denying(bool value) {
    if (_denying == value) return;
    _denying = value;
    refilter();
  }

  final DenyListMode denyMode;

  List<String> _allowedTags = [];
  List<String> get allowedTags => List.unmodifiable(_allowedTags);
  set allowedTags(List<String> value) {
    if (const DeepCollectionEquality().equals(_allowedTags, value)) return;
    _allowedTags = List.from(value);
    refilter();
  }

  List<Post> _allowedPosts = [];
  List<Post> get allowedPosts => List.unmodifiable(_allowedPosts);

  @override
  final ValueNotifier<String> search;
  final bool canSearch;

  late final List<Listenable> _filterNotifiers = [denylist];

  @override
  @protected
  List<Post> filter(List<Post> items) {
    List<String> denylist = [];
    if (denying && denyMode != DenyListMode.unavailable) {
      denylist = this.denylist.items.whereNot(_allowedTags.contains).toList();
    }

    _deniedPosts ??= {};
    List<Post> result = {for (final p in items) p.id: p}.values.toList();

    result.removeWhere((item) {
      if (_allowedPosts.contains(item)) return false;
      List<String>? deniers = item.getDeniers(denylist);
      if (deniers != null) {
        _deniedPosts![item] = deniers;
        if (denyMode != DenyListMode.plain) {
          return true;
        }
      }
      return false;
    });
    _previousDeniedPosts = null;
    return result;
  }

  @override
  @protected
  void refilter() {
    if (rawItemList == null) return;
    if (_deniedPosts != null) {
      _previousDeniedPosts = _deniedPosts;
    }
    _deniedPosts = null;
    super.refilter();
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
  @protected
  @mustCallSuper
  void reset() {
    if (_deniedPosts != null) {
      _previousDeniedPosts = _deniedPosts;
    }
    _deniedPosts = null;
    _allowedPosts = [];
    super.reset();
  }

  @override
  void dispose() {
    _filterNotifiers.forEach((e) => e.removeListener(refilter));
    super.dispose();
  }

  void replacePost(Post post, {bool force = false}) {
    int index = itemList?.indexWhere((e) => e.id == post.id) ?? -1;
    if (index == -1) {
      throw StateError('Post isnt owned by this controller');
    }
    updateItem(index, post, force: force);
  }

  List<String>? getDeniers(Post post) {
    assertOwnsItem(post);
    return (_deniedPosts ?? _previousDeniedPosts!)[post].maybeUnmodifiable();
  }

  bool isDenied(Post post) => getDeniers(post) != null;

  bool isAllowed(Post post) {
    assertOwnsItem(post);
    return _allowedPosts.contains(post);
  }

  void allow(Post post) {
    assertOwnsItem(post);
    _allowedPosts.add(post);
    refilter();
  }

  void unallow(Post post) {
    assertOwnsItem(post);
    _allowedPosts.remove(post);
    refilter();
  }

  Future<bool> fav(Post post) async {
    assertOwnsItem(post);
    replacePost(
      post.copyWith(
        isFavorited: true,
        favCount: post.favCount + 1,
      ),
      force: true,
    );
    try {
      await client.addFavorite(post.id);
      return true;
    } on DioError {
      replacePost(
        post.copyWith(
          isFavorited: false,
          favCount: post.favCount - 1,
        ),
      );
      return false;
    }
  }

  Future<bool> unfav(Post post) async {
    assertOwnsItem(post);
    replacePost(
      post.copyWith(
        isFavorited: false,
        favCount: post.favCount - 1,
      ),
      force: true,
    );
    try {
      await client.removeFavorite(post.id);
      return true;
    } on DioError {
      replacePost(
        post.copyWith(
          isFavorited: true,
          favCount: post.favCount + 1,
        ),
      );
      return false;
    }
  }

  Future<bool> vote({
    required Post post,
    required bool upvote,
    required bool replace,
  }) async {
    assertOwnsItem(post);
    try {
      await client.votePost(post.id, upvote, replace);
      Post value = post;
      if (value.voteStatus == VoteStatus.unknown) {
        if (upvote) {
          value = value.copyWith(
            score: value.score.copyWith(
              total: value.score.total + 1,
              up: value.score.up + 1,
            ),
            voteStatus: VoteStatus.upvoted,
          );
        } else {
          value = value.copyWith(
            score: value.score.copyWith(
              total: value.score.total - 1,
              down: value.score.down + 1,
            ),
            voteStatus: VoteStatus.downvoted,
          );
        }
      } else {
        if (upvote) {
          if (value.voteStatus == VoteStatus.upvoted) {
            value = value.copyWith(
              score: value.score.copyWith(
                total: value.score.total - 1,
                down: value.score.down + 1,
              ),
              voteStatus: VoteStatus.unknown,
            );
          } else {
            value = value.copyWith(
              score: value.score.copyWith(
                total: value.score.total + 2,
                up: value.score.up + 1,
                down: value.score.down - 1,
              ),
              voteStatus: VoteStatus.upvoted,
            );
          }
        } else {
          if (value.voteStatus == VoteStatus.upvoted) {
            value = value.copyWith(
              score: value.score.copyWith(
                total: value.score.total - 2,
                up: value.score.up - 1,
                down: value.score.down + 1,
              ),
              voteStatus: VoteStatus.downvoted,
            );
          } else {
            value = value.copyWith(
              score: value.score.copyWith(
                total: value.score.total + 1,
                up: value.score.up + 1,
              ),
              voteStatus: VoteStatus.unknown,
            );
          }
        }
      }
      replacePost(value);
      return true;
    } on DioError {
      return false;
    }
  }

  Future<void> resetPost(Post post) async {
    assertOwnsItem(post);
    replacePost(await client.post(post.id, force: true));
  }

  // TODO: create a PostUpdate Object instead of a Map
  Future<void> updatePost(Post post, Map<String, String?> body) async {
    assertOwnsItem(post);
    await client.updatePost(post.id, body);
    await resetPost(post);
  }
}

enum DenyListMode {
  unavailable,
  filtering,
  plain,
}

typedef PostProviderCallback = Future<List<Post>> Function(
    String search, int page, bool force)?;

class PostsProvider extends SubChangeNotifierProvider2<Client, DenylistService,
    PostsController> {
  PostsProvider({
    PostProviderCallback provider,
    String? search,
    bool denying = true,
    bool canSearch = true,
    DenyListMode denyMode = DenyListMode.filtering,
    super.child,
    super.builder,
  }) : super(
          create: (context, client, denylist) => PostsController(
            client: client,
            denylist: denylist,
            provider: provider,
            search: search,
            denying: denying,
            canSearch: canSearch,
            denyMode: denyMode,
          ),
        );

  PostsProvider.single({
    required int id,
    DenyListMode denyMode = DenyListMode.plain,
    super.child,
    super.builder,
  }) : super(
          create: (context, client, denylist) => PostsController.single(
            id: id,
            client: client,
            denylist: denylist,
            denyMode: denyMode,
          ),
        );
}

class ExtraPostsController<KeyType, ItemType> extends PostsController {
  ExtraPostsController({
    required super.client,
    required super.denylist,
    required this.parent,
    required this.getIds,
  }) : super(denyMode: DenyListMode.plain) {
    parent.addListener(_onItemsChanged);
  }

  final RawDataController<KeyType, ItemType> parent;
  final List<int> Function(List<ItemType> items) getIds;

  List<int>? _ids;

  List<int>? get ids => _ids.maybeUnmodifiable();

  @override
  void dispose() {
    parent.removeListener(_onItemsChanged);
    super.dispose();
  }

  void _onItemsChanged() {
    if (parent.itemList == null) return;
    if (const DeepCollectionEquality().equals(_ids, getIds(parent.itemList!))) {
      return;
    }
    notifyPageRequestListeners(
      provideNextPageKey(
        nextPageKey ?? firstPageKey,
        itemList ?? [],
      ),
    );
  }

  @override
  @protected
  void reset() {
    _ids = null;
    super.reset();
  }

  @override
  @protected
  Future<List<Post>> provide(int page, bool force) async {
    if (parent.itemList == null) return [];
    List<int> ids = getIds(parent.itemList!);
    if (_ids != null) {
      ids.removeWhere((e) => _ids!.contains(e));
    }
    _ids ??= [];
    _ids!.addAll(ids);
    return client.postsChunk(ids);
  }
}
