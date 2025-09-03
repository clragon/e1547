import 'package:collection/collection.dart';
import 'package:e1547/domain/domain.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/reply/reply.dart';

class ReplyFilter extends FilterController<Reply> {
  ReplyFilter(this.domain) {
    domain.traits.addListener(notifyListeners);
  }

  final Domain domain;

  @override
  List<Reply> filter(List<Reply> items) => items
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
