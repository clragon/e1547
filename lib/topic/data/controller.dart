import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/foundation.dart';

class TopicsController extends PageClientDataController<Topic> {
  TopicsController({required this.client, QueryMap? query})
      : _query = query ?? QueryMap();

  @override
  final Client client;

  QueryMap _query;
  QueryMap get query => _query;
  set query(QueryMap value) {
    if (listEquals(_query.tags, value.tags)) return;
    _query = QueryMap(value);
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
  Future<List<Topic>> fetch(int page, bool force) => client.topics(
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

class TopicsProvider
    extends SubChangeNotifierProvider<Client, TopicsController> {
  TopicsProvider({QueryMap? query, super.child, super.builder})
      : super(
          create: (context, client) =>
              TopicsController(client: client, query: query),
          keys: (context) => [query],
        );
}
