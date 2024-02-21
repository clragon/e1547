import 'package:e1547/interface/interface.dart';
import 'package:e1547/reply/reply.dart';

abstract class RepliesClient {
  Future<Reply> reply({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<List<Reply>> replies({
    required int id,
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<List<Reply>> repliesByTopic({
    required int id,
    int? page,
    int? limit,
    bool? ascending,
    bool? force,
    CancelToken? cancelToken,
  });
}
