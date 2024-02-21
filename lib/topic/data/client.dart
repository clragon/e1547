import 'package:e1547/interface/interface.dart';
import 'package:e1547/topic/topic.dart';

abstract class TopicsClient {
  Future<List<Topic>> topics({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<Topic> topic({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  });
}
