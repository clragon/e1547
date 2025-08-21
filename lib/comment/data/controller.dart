import 'package:collection/collection.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/domain/domain.dart';
import 'package:e1547/query/query.dart';

class CommentFilterController extends FilterController<Comment> {
  CommentFilterController({required this.domain, bool? orderByOldest}) {
    set(_keys.orderByOldest, orderByOldest);
    domain.traits.addListener(notifyListeners);
  }

  final Domain domain;

  final _keys = (orderByOldest: 'orderByOldest');

  bool get orderByOldest => get<bool>(_keys.orderByOldest) ?? true;
  set orderByOldest(bool value) => set(_keys.orderByOldest, value);

  @override
  List<List<Comment>> filter(List<List<Comment>> items) => items
      .map(
        (page) => page
            .whereNot(
              (e) =>
                  domain.traits.value.denylist.contains('user:${e.creatorId}'),
            )
            .toList(),
      )
      .toList();

  @override
  void dispose() {
    domain.traits.removeListener(notifyListeners);
    super.dispose();
  }
}
