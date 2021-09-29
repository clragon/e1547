import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';

import 'reply.dart';

class ReplyController extends CursorDataController<Reply>
    with RefreshableController {
  final int topicId;

  ReplyController({required this.topicId});

  @override
  Future<List<Reply>> provide(String page) => client.replies(topicId, page);

  @override
  int getId(Reply item) => item.id;
}
