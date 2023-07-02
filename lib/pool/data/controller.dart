import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class PoolsController extends PageClientDataController<Pool> {
  PoolsController({
    required this.client,
    required this.denylist,
    String? search,
  })  : _search = search ?? '',
        thumbnails = ThumbnailController(
          client: client,
          denylist: denylist,
        );

  @override
  final Client client;
  final DenylistService denylist;

  final ThumbnailController thumbnails;

  String _search = '';
  String get search => _search;
  set search(String value) {
    if (value == _search) return;
    _search = value;
    refresh();
  }

  @override
  @protected
  void reset() {
    thumbnails.reset();
    super.reset();
  }

  @override
  @protected
  Future<List<Pool>> fetch(int page, bool force) async {
    List<Pool> pools = await client.pools(
      page,
      search: search,
      force: force,
      cancelToken: cancelToken,
    );
    List<int> ids = pools
        .map((e) => e.postIds.isNotEmpty ? e.postIds.first : null)
        .where((e) => e != null)
        .toList()
        .cast<int>();
    await thumbnails.loadIds(ids, force: force);
    return pools;
  }
}

class PoolsProvider extends SubChangeNotifierProvider2<Client, DenylistService,
    PoolsController> {
  PoolsProvider({String? search, super.child, super.builder})
      : super(
          create: (context, client, denylist) => PoolsController(
            client: client,
            denylist: denylist,
            search: search,
          ),
          keys: (context) => [search],
        );
}

class ThumbnailController extends PostsController {
  ThumbnailController({
    required super.client,
    required super.denylist,
  });

  Map<int, List<int>> _ids = {};

  @override
  @protected
  @mustCallSuper
  void reset() {
    _ids = {};
    super.reset();
  }

  Future<void> loadIds(List<int> ids, {bool force = false}) async {
    _ids[_ids.length] = ids;
    await getNextPage();
  }

  @override
  @protected
  Future<List<Post>> fetch(int page, bool force) async {
    List<int>? ids = _ids[page];
    if (ids == null) return [];
    List<int> available = rawItems?.map((e) => e.id).toList() ?? [];
    ids.removeWhere(available.contains);
    return client.postsByIds(
      ids,
      force: force,
      cancelToken: cancelToken,
    );
  }
}

class PoolController extends PostsController {
  PoolController({
    required super.client,
    required super.denylist,
    required this.pool,
    bool orderByOldest = true,
  }) : super(
          orderPools: orderByOldest,
          canSearch: false,
        );

  final Pool pool;

  @override
  @protected
  Future<List<Post>> fetch(int page, bool force) async => client.poolPosts(
        pool.id,
        page,
        orderByOldest: orderPools,
        force: force,
        cancelToken: cancelToken,
      );
}
