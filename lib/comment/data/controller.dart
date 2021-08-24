import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';

import 'comment.dart';

class CommentController extends CursorDataController<Comment>
    with RefreshableDataMixin {
  final int postId;

  CommentController({required this.postId});

  @override
  Future<List<Comment>> provide(String page) => client.comments(postId, page);

  @override
  int getId(Comment item) => item.id;
}
