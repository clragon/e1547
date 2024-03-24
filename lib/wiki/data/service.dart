import 'package:e1547/interface/interface.dart';
import 'package:e1547/wiki/wiki.dart';

abstract class WikiService {
  Future<Wiki> get({
    required String id,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<List<Wiki>> page({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  });
}
