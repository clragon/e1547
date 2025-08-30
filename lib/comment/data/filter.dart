import 'package:collection/collection.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/domain/domain.dart';
import 'package:e1547/query/query.dart';

class CommentFilter extends FilterController<Comment> {
  CommentFilter(this.domain);

  final Domain domain;

  @override
  List<Comment> filter(List<Comment> items) => items
      .whereNot(
        (e) => domain.traits.value.denylist.contains('user:${e.creatorId}'),
      )
      .toList();

  @override
  void dispose() {
    domain.traits.removeListener(notifyListeners);
    super.dispose();
  }
}
