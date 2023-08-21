import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/foundation.dart';

class PoolsController extends PageClientDataController<Pool> {
  PoolsController({
    required this.client,
    required this.denylist,
    QueryMap? search,
  })  : _search = search ?? QueryMap(),
        thumbnails = ThumbnailController(
          client: client,
          denylist: denylist,
        );

  @override
  final Client client;
  final DenylistService denylist;

  final ThumbnailController thumbnails;

  QueryMap _search;
  QueryMap get search => _search;
  set search(QueryMap value) {
    if (mapEquals(_search, value)) return;
    _search = QueryMap.from(value);
    refresh();
  }

  @override
  @protected
  void reset() {
    thumbnails.resetIds();
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
  PoolsProvider({QueryMap? search, super.child, super.builder})
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
  int? get nextPageKey => _ids.length;

  void resetIds() => _ids = {};

  Future<void> loadIds(List<int> ids, {bool force = false}) async {
    _ids[nextPageKey! + 1] = ids;
    await getNextPage(reset: force);
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
    required this.id,
    bool orderByOldest = true,
  }) : super(
          orderPools: orderByOldest,
          canSearch: false,
        );

  final int id;

  @override
  @protected
  Future<List<Post>> fetch(int page, bool force) async => client.poolPosts(
        id,
        page,
        orderByOldest: orderPools,
        force: force,
        cancelToken: cancelToken,
      );
}
