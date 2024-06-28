import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';

abstract class TagService {
  // Technically missing get()
  Future<List<Tag>> page({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<List<Tag>> autocomplete({
    String? search,
    int? limit,
    int? category,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<String?> aliases({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  });
}
