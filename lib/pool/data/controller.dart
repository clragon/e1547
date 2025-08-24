import 'package:e1547/post/post.dart';
import 'package:flutter/foundation.dart';

class PoolPostController extends PostController {
  PoolPostController({
    required super.domain,
    required this.id,
    bool orderByOldest = true,
  }) : super(orderPools: orderByOldest, canSearch: false);

  final int id;

  @override
  @protected
  Future<List<Post>> fetch(int page, bool force) async => domain.posts.byPool(
    id: id,
    page: page,
    orderByOldest: orderPools,
    force: force,
    cancelToken: cancelToken,
  );
}
