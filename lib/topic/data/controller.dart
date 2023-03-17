import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/material.dart';

class TopicsController extends PageClientDataController<Topic>
    with RefreshableController, SearchableController, FilterableController {
  TopicsController({required this.client, String? search})
      : search = ValueNotifier<String>(search ?? '') {
    _filterNotifiers.forEach((e) => e.addListener(refilter));
  }

  @override
  final Client client;

  @override
  late ValueNotifier<String> search;

  final ValueNotifier<bool> hideTagEditing = ValueNotifier<bool>(true);

  late final List<Listenable> _filterNotifiers = [hideTagEditing];

  @override
  @protected
  Future<List<Topic>> fetch(int page, bool force) => client.topics(
        page,
        search: search.value,
        force: force,
        cancelToken: cancelToken,
      );

  @override
  List<Topic> filter(List<Topic> items) {
    if (hideTagEditing.value) {
      return items.where((e) => e.categoryId != 2).toList();
    }
    return items;
  }

  @override
  void dispose() {
    _filterNotifiers.forEach((e) => e.removeListener(refilter));
    super.dispose();
  }
}

class TopicsProvider
    extends SubChangeNotifierProvider<Client, TopicsController> {
  TopicsProvider({String? search, super.child, super.builder})
      : super(
          create: (context, client) =>
              TopicsController(client: client, search: search),
          keys: (context) => [search],
        );
}
