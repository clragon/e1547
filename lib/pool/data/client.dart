import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';

abstract class PoolsClient {
  Future<Pool> pool({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<List<Pool>> pools({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<List<Post>> postsByPool({
    required int id,
    int? page,
    int? limit,
    bool orderByOldest = true,
    bool? force,
    CancelToken? cancelToken,
  });
}
