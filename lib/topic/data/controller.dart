import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/material.dart';

class TopicsController extends DataController<Topic>
    with RefreshableController, SearchableController {
  final Client client;

  @override
  late ValueNotifier<String> search;

  TopicsController({required this.client, String? search})
      : search = ValueNotifier<String>(search ?? '');

  @override
  @protected
  Future<List<Topic>> provide(int page, bool force) =>
      client.topics(page, search: search.value, force: force);
}

class TopicsProvider
    extends SelectiveChangeNotifierProvider<Client, TopicsController> {
  TopicsProvider({String? search, super.child, super.builder})
      : super(
          create: (context, client) =>
              TopicsController(client: client, search: search),
          selector: (context, client) => [search],
        );
}
