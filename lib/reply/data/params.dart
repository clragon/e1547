import 'package:e1547/query/query.dart';
import 'package:e1547/tag/tag.dart';

enum ReplyOrder {
  newest('id_desc'),
  oldest('id_asc');

  const ReplyOrder(this.value);

  final String value;
}

class ReplyParams extends ParamsController {
  ReplyParams({ProtoMap? value}) : super(value?.toQuery());

  static const topicIdFilter = NumberFilterTag(
    tag: 'search[topic_id]',
    name: 'Topic ID',
  );

  static const bodyFilter = TextFilterTag(
    tag: 'search[body_matches]',
    name: 'Body contains',
  );

  static const creatorFilter = TextFilterTag(
    tag: 'search[creator_name]',
    name: 'Creator',
  );

  static final orderFilter = EnumFilterTag<ReplyOrder>(
    tag: 'search[order]',
    name: 'Sort by',
    values: ReplyOrder.values,
    valueMapper: (value) => value.value,
    nameMapper: (value) => switch (value) {
      ReplyOrder.newest => 'Newest first',
      ReplyOrder.oldest => 'Oldest first',
    },
  );

  int? get topicId => getFilter(topicIdFilter);
  set topicId(int? value) => setFilter(topicIdFilter, value);

  String? get body => getFilter(bodyFilter);
  set body(String? value) => setFilter(bodyFilter, value);

  String? get creator => getFilter(creatorFilter);
  set creator(String? value) => setFilter(creatorFilter, value);

  ReplyOrder get order => getFilterEnum(orderFilter) ?? ReplyOrder.oldest;
  set order(ReplyOrder value) => setFilterEnum(orderFilter, value);
}
