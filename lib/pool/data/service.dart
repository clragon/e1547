import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';

abstract class PoolService {
  Future<Pool> get({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<List<Pool>> page({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<List<Post>> byPool({
    required int id,
    int? page,
    int? limit,
    bool orderByOldest = true,
    bool? force,
    CancelToken? cancelToken,
  });
}
