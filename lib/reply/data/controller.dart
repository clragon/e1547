import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/reply/reply.dart';
import 'package:flutter/material.dart';

class RepliesController extends CursorDataController<Reply>
    with RefreshableController {
  RepliesController({
    required this.client,
    required this.topicId,
    bool orderByOldest = true,
  }) : orderByOldest = ValueNotifier(orderByOldest);

  final Client client;

  final int topicId;
  @override
  final ValueNotifier<bool> orderByOldest;

  @override
  @protected
  Future<List<Reply>> provide(String page, bool force) =>
      client.replies(topicId, page, force: force);

  @override
  @protected
  int getId(Reply item) => item.id;
}

class RepliesProvider
    extends SubChangeNotifierProvider<Client, RepliesController> {
  RepliesProvider({
    required int topicId,
    bool orderByOldest = true,
    super.child,
    super.builder,
  }) : super(
          create: (context, client) => RepliesController(
              client: client, topicId: topicId, orderByOldest: orderByOldest),
          selector: (context) => [topicId, orderByOldest],
        );
}
