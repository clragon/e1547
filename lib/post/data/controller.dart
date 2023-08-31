import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/data/map.dart';
import 'package:flutter/material.dart';

class PostsController extends PageClientDataController<Post>
    with PostsActionController, PostFilterableController {
  PostsController({
    required this.client,
    required this.denylist,
    QueryMap? query,
    bool orderFavorites = false,
    bool orderPools = true,
    bool denying = true,
    this.canSearch = true,
    this.filterMode = PostFilterMode.filtering,
  })  : _query = query ?? QueryMap(),
        _orderFavorites = orderFavorites,
        _orderPools = orderPools {
    this.denying = denying;
    denylist.addListener(applyFilter);
  }

  @override
  final Client client;

  final bool canSearch;
  QueryMap _query;
  QueryMap get query => _query;
  set query(QueryMap value) {
    if (value == _query) return;
    _query = QueryMap(value);
    refresh();
  }

  @override
  final PostFilterMode filterMode;
  @override
  final DenylistService denylist;

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
  Future<List<Post>> fetch(int page, bool force) async => client.posts(
        page: page,
        query: query,
        force: force,
        orderPoolsByOldest: orderPools,
        orderFavoritesByAdded: orderFavorites,
        cancelToken: cancelToken,
      );

  @override
  void dispose() {
    denylist.removeListener(applyFilter);
    super.dispose();
  }
}

class SinglePostController extends PostsController {
  SinglePostController({
    required this.id,
    required super.client,
    required super.denylist,
    super.filterMode = PostFilterMode.plain,
  }) : super(canSearch: false);

  final int id;

  @override
  Future<List<Post>> fetch(int page, bool force) async => [
        if (page == firstPageKey)
          await client.post(
            id,
            force: force,
            cancelToken: cancelToken,
          ),
      ];
}

class PostsProvider extends SubChangeNotifierProvider2<Client, DenylistService,
    PostsController> {
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
          create: (context, client, denylist) => PostsController(
            client: client,
            denylist: denylist,
            query: query,
            orderFavorites: orderFavorites,
            orderPools: orderPools,
            denying: denying,
            canSearch: canSearch,
            filterMode: filterMode,
          ),
        );

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
          create: (context, client, denylist) => SinglePostController(
            id: id,
            client: client,
            denylist: denylist,
            filterMode: filterMode,
          ),
        );
}
