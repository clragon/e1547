import 'package:e1547/interface/interface.dart';
import 'package:e1547/topic/topic.dart';

abstract class TopicService {
  Future<Topic> get({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<List<Topic>> page({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  });
}
