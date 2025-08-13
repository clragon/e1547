import 'package:e1547/domain/domain.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/foundation.dart';

class TopicController extends PageClientDataController<Topic> {
  TopicController({required this.domain, QueryMap? query})
    : _query = query ?? QueryMap();

  @override
  final Domain domain;

  QueryMap _query;
  QueryMap get query => _query;
  set query(QueryMap value) {
    if (mapEquals(_query, value)) return;
    _query = Map.of(value);
    refresh();
  }

  bool _hideTagEditing = true;
  bool get hideTagEditing => _hideTagEditing;
  set hideTagEditing(bool value) {
    if (value == _hideTagEditing) return;
    _hideTagEditing = value;
    applyFilter();
  }

  @override
  @protected
  Future<List<Topic>> fetch(int page, bool force) => domain.topics.page(
    page: page,
    query: query,
    force: force,
    cancelToken: cancelToken,
  );

  @override
  List<Topic>? filter(List<Topic>? items) {
    List<Topic>? result = super.filter(items);
    if (hideTagEditing) {
      return result?.where((e) => e.categoryId != 2).toList();
    }
    return result;
  }
}

class TopicProvider extends SubChangeNotifierProvider<Domain, TopicController> {
  TopicProvider({QueryMap? query, super.child, super.builder})
    : super(
        create: (context, client) =>
            TopicController(domain: client, query: query),
        keys: (context) => [query],
      );
}
