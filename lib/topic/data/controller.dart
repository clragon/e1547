import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/foundation.dart';

class TopicsController extends PageClientDataController<Topic> {
  TopicsController({required this.client, QueryMap? search})
      : _search = search ?? QueryMap();

  @override
  final Client client;

  QueryMap _search;
  QueryMap get search => _search;
  set search(QueryMap value) {
    if (mapEquals(value, _search)) return;
    _search = QueryMap.from(value);
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
        page,
        search: search,
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
  TopicsProvider({QueryMap? search, super.child, super.builder})
      : super(
          create: (context, client) =>
              TopicsController(client: client, search: search),
          keys: (context) => [search],
        );
}
