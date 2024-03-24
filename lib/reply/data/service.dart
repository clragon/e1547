import 'package:e1547/interface/interface.dart';
import 'package:e1547/reply/reply.dart';

abstract class ReplyService {
  Future<Reply> get({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<List<Reply>> page({
    required int id,
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<List<Reply>> byTopic({
    required int id,
    int? page,
    int? limit,
    bool? ascending,
    bool? force,
    CancelToken? cancelToken,
  });
}
