import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/reply/reply.dart';
import 'package:flutter/material.dart';

class RepliesController extends CursorClientDataController<Reply>
    with RefreshableController, FilterableController {
  RepliesController({
    required this.client,
    required this.topicId,
    required this.denylist,
    bool? orderByOldest,
  }) : orderByOldest = ValueNotifier<bool>(orderByOldest ?? true) {
    _filterNotifiers.forEach((e) => e.addListener(refilter));
  }

  @override
  final Client client;

  final int topicId;
  @override
  // ignore: overridden_fields
  final ValueNotifier<bool> orderByOldest;

  final DenylistService denylist;
  late final List<Listenable> _filterNotifiers = [denylist];

  @override
  @protected
  Future<List<Reply>> fetch(String page, bool force) => client.replies(
        topicId,
        page,
        force: force,
        cancelToken: cancelToken,
      );

  @override
  @protected
  int getId(Reply item) => item.id;

  @override
  List<Reply> filter(List<Reply> items) =>
      items.whereNot((e) => denylist.denies('user:${e.creatorId}')).toList();

  @override
  void dispose() {
    _filterNotifiers.forEach((e) => e.removeListener(refilter));
    super.dispose();
  }
}

class RepliesProvider extends SubChangeNotifierProvider2<Client,
    DenylistService, RepliesController> {
  RepliesProvider({
    required int topicId,
    bool? orderByOldest,
    super.child,
    super.builder,
  }) : super(
          create: (context, client, denylist) => RepliesController(
            client: client,
            topicId: topicId,
            denylist: denylist,
            orderByOldest: orderByOldest,
          ),
          keys: (context) => [topicId, orderByOldest],
        );
}
