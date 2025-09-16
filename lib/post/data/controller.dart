import 'package:e1547/client/client.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/foundation.dart';

class PostController extends PageClientDataController<Post>
    with PostActionController, PostFilterableController {
  PostController({
    required this.client,
    QueryMap? query,
    bool orderFavorites = false,
    bool orderPools = true,
    bool denying = true,
    this.canSearch = true,
    this.filterMode = PostFilterMode.filtering,
  }) : _query = query ?? {},
       _orderFavorites = orderFavorites,
       _orderPools = orderPools {
    this.denying = denying;
    client.traits.addListener(applyFilter);
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
    client.traits.removeListener(applyFilter);
    super.dispose();
  }
}

class SinglePostController extends PostController {
  SinglePostController({
    required this.id,
    required super.client,
    super.filterMode = PostFilterMode.plain,
  }) : super(canSearch: false);

  final int id;

  @override
  Future<List<Post>> fetch(int page, bool force) async => [
    if (page == firstPageKey)
      await client.posts.get(id: id, force: force, cancelToken: cancelToken),
  ];
}

class PostProvider extends SubChangeNotifierProvider<Client, PostController> {
  PostProvider({
    QueryMap? query,
    bool orderFavorites = false,
    bool orderPools = true,
    bool denying = true,
    bool canSearch = true,
    PostFilterMode filterMode = PostFilterMode.filtering,
    super.child,
    super.builder,
  }) : super(
         create: (context, client) => PostController(
           client: client,
           query: query,
           orderPools: orderPools,
           denying: denying,
           canSearch: canSearch,
           filterMode: filterMode,
         ),
       );

  // ignore: use_key_in_widget_constructors
  PostProvider.builder({
    required super.create,
    super.keys,
    super.child,
    super.builder,
  });
}

class SinglePostProvider extends PostProvider {
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
