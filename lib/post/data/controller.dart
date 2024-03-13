import 'package:e1547/client/client.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/foundation.dart';

class PostsController extends PageClientDataController<Post>
    with PostsActionController, PostFilterableController {
  PostsController({
    required this.client,
    QueryMap? query,
    bool orderFavorites = false,
    bool orderPools = true,
    bool denying = true,
    this.canSearch = true,
    this.filterMode = PostFilterMode.filtering,
  })  : _query = query ?? {},
        _orderFavorites = orderFavorites,
        _orderPools = orderPools {
    this.denying = denying;
    client.traitsState.addListener(applyFilter);
  }

  @override
  final Client client;

  final bool canSearch;
  QueryMap _query;
  QueryMap get query => _query;
  set query(QueryMap value) {
    if (mapEquals(_query, value)) return;
    _query = Map.of(value);
    refresh();
  }

  @override
  final PostFilterMode filterMode;

  bool _orderFavorites;

  /// Order posts by when they were added to favorites.
  bool get orderFavorites => _orderFavorites;
  set orderFavorites(bool value) {
    if (value == _orderFavorites) return;
    _orderFavorites = value;
    refresh();
  }

  bool _orderPools;

  /// Order posts by pool order.
  bool get orderPools => _orderPools;
  set orderPools(bool value) {
    if (value == _orderPools) return;
    _orderPools = value;
    refresh();
  }

  @override
  @protected
  Future<List<Post>> fetch(int page, bool force) async => client.posts.page(
        page: page,
        query: query,
        force: force,
        orderPoolsByOldest: orderPools,
        orderFavoritesByAdded: orderFavorites,
        cancelToken: cancelToken,
      );

  @override
  void dispose() {
    client.traitsState.removeListener(applyFilter);
    super.dispose();
  }
}

class SinglePostController extends PostsController {
  SinglePostController({
    required this.id,
    required super.client,
    super.filterMode = PostFilterMode.plain,
  }) : super(canSearch: false);

  final int id;

  @override
  Future<List<Post>> fetch(int page, bool force) async => [
        if (page == firstPageKey)
          await client.posts.get(
            id,
            force: force,
            cancelToken: cancelToken,
          ),
      ];
}

class PostsProvider extends SubChangeNotifierProvider<Client, PostsController> {
  PostsProvider({
    QueryMap? query,
    bool orderFavorites = false,
    bool orderPools = true,
    bool denying = true,
    bool canSearch = true,
    PostFilterMode filterMode = PostFilterMode.filtering,
    super.child,
    super.builder,
  }) : super(
          create: (context, client) => PostsController(
            client: client,
            query: query,
            orderPools: orderPools,
            denying: denying,
            canSearch: canSearch,
            filterMode: filterMode,
          ),
        );

  // ignore: use_key_in_widget_constructors
  PostsProvider.builder({
    required super.create,
    super.keys,
    super.child,
    super.builder,
  });
}

class SinglePostProvider extends PostsProvider {
  SinglePostProvider({
    required int id,
    PostFilterMode filterMode = PostFilterMode.plain,
    super.child,
    super.builder,
  }) : super.builder(
          create: (context, client) => SinglePostController(
            id: id,
            client: client,
            filterMode: filterMode,
          ),
        );
}
