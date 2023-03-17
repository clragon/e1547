import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class PoolsController extends PageClientDataController<Pool>
    with SearchableController, RefreshableController {
  PoolsController({
    required this.client,
    required this.denylist,
    String? search,
  })  : search = ValueNotifier<String>(search ?? ''),
        thumbnails = ThumbnailController(
          client: client,
          denylist: denylist,
        );

  @override
  final Client client;
  final DenylistService denylist;

  @override
  late ValueNotifier<String> search;

  final ThumbnailController thumbnails;

  @override
  @protected
  void reset({bool hasLoaded = false}) {
    if (!hasLoaded) {
      thumbnails.reset();
    }
    super.reset(hasLoaded: hasLoaded);
  }

  @override
  @protected
  List<Listenable> getRefreshListeners() =>
      super.getRefreshListeners()..add(search);

  @override
  @protected
  Future<List<Pool>> fetch(int page, bool force) async {
    List<Pool> pools = await client.pools(
      page,
      search: search.value,
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
  }) : super(filterMode: PostFilterMode.plain);

  Map<int, List<int>> _ids = {};

  @override
  void reset({bool hasLoaded = false}) {
    _ids = {};
    super.reset(hasLoaded: hasLoaded);
  }

  Future<void> loadIds(List<int> ids, {bool force = false}) async {
    int index = _ids.length;
    _ids[index] = ids;
    await loadPage(index, force: force);
  }

  @override
  @protected
  Future<List<Post>> fetch(int page, bool force) async {
    List<int>? ids = _ids[page];
    if (ids == null) return [];
    List<int> available = itemList?.map((e) => e.id).toList() ?? [];
    ids.removeWhere(available.contains);
    return client.postsChunk(
      ids,
      force: force,
      cancelToken: cancelToken,
    );
  }
}
