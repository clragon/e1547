import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';

import 'comment.dart';

class CommentController extends CursorDataController<Comment>
    with RefreshableController, HostableController {
  final int postId;

  CommentController({required this.postId});

  @override
  Future<List<Comment>> provide(String page, bool force) =>
      client.comments(postId, page, force: force);

  @override
  int getId(Comment item) => item.id;

  @override
  void disposeItems(List<Comment> items) async {
    for (final comment in items) {
      comment.dispose();
    }
  }
}
