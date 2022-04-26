import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

import 'reply.dart';

class ReplyController extends CursorDataController<Reply>
    with RefreshableController {
  final int topicId;
  @override
  final ValueNotifier<bool> orderByOldest;

  ReplyController({required this.topicId, bool orderByOldest = true})
      : orderByOldest = ValueNotifier(orderByOldest);

  @override
  @protected
  Future<List<Reply>> provide(String page, bool force) =>
      client.replies(topicId, page, force: force);

  @override
  @protected
  int getId(Reply item) => item.id;
}
