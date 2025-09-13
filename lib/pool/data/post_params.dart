import 'package:e1547/query/query.dart';
import 'package:e1547/tag/tag.dart';

class PoolPostParams extends ParamsController {
  PoolPostParams({ProtoMap? value}) : super(value?.toQuery());

  static const orderByOldestFilter = BooleanFilterTag(
    tag: 'order_by_oldest',
    name: 'Order by oldest',
    description: 'Order posts from oldest to newest',
  );

  bool get orderByOldest => getFilterBool(orderByOldestFilter) ?? true;
  set orderByOldest(bool? value) => setFilterBool(orderByOldestFilter, value);
}
