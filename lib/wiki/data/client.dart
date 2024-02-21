import 'package:e1547/interface/interface.dart';
import 'package:e1547/wiki/wiki.dart';

abstract class WikisClient {
  Future<Wiki> wiki({
    required String id,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<List<Wiki>> wikis({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  });
}
