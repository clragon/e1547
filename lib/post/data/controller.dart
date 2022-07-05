import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

enum DenyListMode {
  unavailable,
  filtering,
  plain,
}

typedef PostProviderCallback = Future<List<Post>> Function(
    String search, int page, bool force)?;

class PostsController extends DataController<Post>
    with SearchableController, HostableController, RefreshableController {
  final PostProviderCallback _provider;

  Map<String, List<Post>>? _previousDeniedPosts;
  Map<String, List<Post>>? _deniedPosts;
  Map<String, List<Post>>? get deniedPosts =>
      _deniedPosts != null ? Map.unmodifiable(_deniedPosts!) : null;

  bool _denying;
  bool get denying => _denying;

  final DenyListMode denyMode;

  List<String> _allowedTags = [];
  List<String> get allowedTags => List.unmodifiable(_allowedTags);

  List<Post> _allowedPosts = [];
  List<Post> get allowedPosts => List.unmodifiable(_allowedPosts);

  List<Post>? _posts;

  @override
  ValueNotifier<String> search;
  bool canSearch;

  late final List<Listenable> _filterNotifiers = [denylistController];

  PostsController({
    PostProviderCallback provider,
    String? search,
    bool denying = true,
    this.canSearch = true,
    this.denyMode = DenyListMode.filtering,
  })  : _provider = provider,
        _denying = denying,
        search = ValueNotifier(sortTags(search ?? '')) {
    for (final element in _filterNotifiers) {
      element.addListener(reapplyFilter);
    }
  }

  factory PostsController.single(
    int id, {
    DenyListMode denyMode = DenyListMode.plain,
  }) {
    late PostsController controller;
    controller = PostsController(
      provider: (search, page, force) async => page == controller.firstPageKey
          ? [await client.post(id, force: force)]
          : [],
      canSearch: false,
      denyMode: denyMode,
    );
    return controller;
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
    if (_deniedPosts != null) {
      _previousDeniedPosts = _deniedPosts;
    }
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
}

class PostController extends ProxyValueNotifier<Post, PostsController> {
  final int? id;

  PostController({required this.id, required super.parent}) {
    _registerDenying();
  }

  PostController.single(super.value)
      : id = null,
        super.single() {
    _registerDenying();
  }

  @override
  Post? fromParent() =>
      parent?.itemList?.firstWhereOrNull((value) => value.id == id);

  @override
  void toParent(Post value) {
    if (!orphan) {
      parent!.updateItem(
        parent!.itemList!.indexOf(this.value),
        value,
        force: true,
      );
    }
  }

  void _registerDenying() {
    if (!orphan) {
      parent!.addListener(_updateDenied);
      parent!.addListener(_updateAllowed);
    } else {
      denylistController.addListener(_updateDenied);
    }
    _updateDenied();
    _updateAllowed();
  }

  void _updateDenied() {
    if (!orphan) {
      _isDenied = parent!.isDenied(value);
    } else {
      _isDenied = value.isDeniedBy(denylistController.items) && !_isAllowed;
    }
    notifyListeners();
  }

  void _updateAllowed() {
    if (!orphan) {
      _isAllowed = parent!.isAllowed(value);
      notifyListeners();
    }
  }

  bool _isDenied = false;
  bool get isDenied => _isDenied;

  bool _isAllowed = false;
  bool get isAllowed => _isAllowed;
  set isAllowed(bool value) {
    if (!orphan) {
      if (value) {
        parent!.allow(this.value);
      } else {
        parent!.unallow(this.value);
      }
    } else {
      _isAllowed = value;
      _updateDenied();
    }
  }

  @override
  void dispose() {
    parent?.addListener(_updateDenied);
    parent?.addListener(_updateAllowed);
    denylistController.removeListener(_updateDenied);
    super.dispose();
  }

  Future<bool> fav() async {
    value = value.copyWith(
      isFavorited: true,
      favCount: value.favCount + 1,
    );
    try {
      await client.addFavorite(value.id);
      return true;
    } on DioError {
      value = value.copyWith(
        isFavorited: false,
        favCount: value.favCount - 1,
      );
      return false;
    }
  }

  Future<bool> unfav() async {
    value = value.copyWith(
      isFavorited: false,
      favCount: value.favCount - 1,
    );
    try {
      await client.removeFavorite(value.id);
      return true;
    } on DioError {
      value = value.copyWith(
        isFavorited: true,
        favCount: value.favCount + 1,
      );
      return false;
    }
  }

  Future<bool> vote({
    required bool upvote,
    required bool replace,
  }) async {
    try {
      await client.votePost(value.id, upvote, replace);
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
      return true;
    } on DioError {
      return false;
    }
  }

  Future<void> reset() async {
    value = await client.post(value.id, force: true);
  }
}
