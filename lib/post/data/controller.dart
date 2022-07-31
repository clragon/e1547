import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum DenyListMode {
  unavailable,
  filtering,
  plain,
}

typedef PostProviderCallback = Future<List<Post>> Function(
    String search, int page, bool force)?;

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
    _denying = value;
    refilter();
  }

  final DenyListMode denyMode;

  List<String> _allowedTags = [];
  List<String> get allowedTags => List.unmodifiable(_allowedTags);
  set allowedTags(List<String> value) {
    _allowedTags = List.from(value);
    refilter();
  }

  List<Post> _allowedPosts = [];
  List<Post> get allowedPosts => List.unmodifiable(_allowedPosts);

  @override
  final ValueNotifier<String> search;
  final bool canSearch;

  @override
  @protected
  List<Listenable> getRefreshListeners() =>
      super.getRefreshListeners()..add(client);

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
}

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

class PostController extends ProxyValueNotifier<Post, PostsController> {
  final Client client;
  final DenylistService denylist;

  final int id;

  PostController({
    required this.client,
    required this.denylist,
    required this.id,
    required super.parent,
  }) {
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
      denylist.addListener(_updateDenied);
    }
    _updateDenied();
    _updateAllowed();
  }

  void _updateDenied() {
    if (!orphan) {
      _deniers = parent!.getDeniers(value);
    } else {
      if (_isAllowed) {
        _deniers = null;
      } else {
        _deniers = value.getDeniers(denylist.items);
      }
    }
    notifyListeners();
  }

  void _updateAllowed() {
    if (!orphan) {
      _isAllowed = parent!.isAllowed(value);
      notifyListeners();
    }
  }

  List<String>? _deniers;
  List<String>? get deniers => _deniers.maybeUnmodifiable();
  bool get isDenied => _deniers != null;

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
    parent?.removeListener(_updateDenied);
    parent?.removeListener(_updateAllowed);
    denylist.removeListener(_updateDenied);
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

class PostProvider extends SubChangeNotifierProvider2<Client, DenylistService,
    PostController> {
  PostProvider({
    required int id,
    PostsController? parent,
    super.child,
    super.builder,
  }) : super(
          create: (context, client, denylist) => PostController(
            client: client,
            denylist: denylist,
            id: id,
            parent: parent ?? context.read<PostsController>(),
          ),
          selector: (context) =>
              [id, parent ?? context.watch<PostsController>()],
        );
}
