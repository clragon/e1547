import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';

abstract class TagsClient {
  // Technically missing tags()
  Future<List<Tag>> tags({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<List<TagSuggestion>> autocomplete({
    required String search,
    int? category,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<String?> tagAliases({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  });
}
