import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/foundation.dart';

class PoolController extends PageClientDataController<Pool> {
  PoolController({
    required this.client,
    QueryMap? query,
  })  : _query = query ?? QueryMap(),
        thumbnails = ThumbnailController(client: client);

  @override
  final Client client;

  final ThumbnailController thumbnails;

  QueryMap _query;
  QueryMap get query => _query;
  set query(QueryMap value) {
    if (mapEquals(_query, value)) return;
    _query = Map.of(value);
    refresh();
  }

  @override
  void onPreRequest(bool force, bool reset, bool background) {
    if (reset) thumbnails.resetIds();
    super.onPreRequest(force, reset, background);
  }

  @override
  @protected
  Future<List<Pool>> fetch(int page, bool force) async {
    List<Pool> pools = await client.pools.page(
      page: page,
      query: query,
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

class PoolsProvider extends SubChangeNotifierProvider<Client, PoolController> {
  PoolsProvider({QueryMap? search, super.child, super.builder})
      : super(
          create: (context, client) => PoolController(
            client: client,
            query: search,
          ),
          keys: (context) => [search],
        );
}

class ThumbnailController extends PostController {
  ThumbnailController({required super.client});

  Map<int, List<int>> _ids = {};

  @override
  int? get nextPageKey => _ids.length;

  void resetIds() => _ids = {};

  Future<void> loadIds(List<int> ids, {bool force = false}) async {
    _ids[nextPageKey! + 1] = ids;
    await getNextPage(force: force);
  }

  @override
  @protected
  Future<List<Post>> fetch(int page, bool force) async {
    List<int>? ids = _ids[page];
    if (ids == null) return [];
    List<int> available = rawItems?.map((e) => e.id).toList() ?? [];
    ids.removeWhere(available.contains);
    return client.posts.byIds(
      ids: ids,
      force: force,
      cancelToken: cancelToken,
    );
  }
}

class PoolPostController extends PostController {
  PoolPostController({
    required super.client,
    required this.id,
    bool orderByOldest = true,
  }) : super(
          orderPools: orderByOldest,
          canSearch: false,
        );

  final int id;

  @override
  @protected
  Future<List<Post>> fetch(int page, bool force) async => client.pools.byPool(
        id: id,
        page: page,
        orderByOldest: orderPools,
        force: force,
        cancelToken: cancelToken,
      );
}
