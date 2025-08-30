import 'package:e1547/pool/pool.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/tag/tag.dart';

enum PoolOrder {
  newest('id_desc'),
  oldest('id_asc'),
  name('name'),
  created('created_at'),
  updated('updated_at'),
  postCount('post_count');

  const PoolOrder(this.value);

  final String value;
}

enum PoolCategory {
  series('series'),
  collection('collection');

  const PoolCategory(this.value);

  final String value;
}

class PoolParams extends ParamsController<Pool> {
  PoolParams({ProtoMap? value}) : super(value?.toQuery());

  static const nameFilter = TextFilterTag(
    tag: 'search[name_matches]',
    name: 'Name',
  );

  static const descriptionFilter = TextFilterTag(
    tag: 'search[description_matches]',
    name: 'Description',
  );

  static const creatorFilter = TextFilterTag(
    tag: 'search[creator_name]',
    name: 'Creator',
  );

  static const activeFilter = BooleanFilterTag(
    tag: 'search[is_active]',
    name: 'Active',
    description: 'Is active',
    tristate: true,
  );

  static final categoryFilter = EnumFilterTag<PoolCategory>(
    tag: 'search[category]',
    name: 'Category',
    values: PoolCategory.values,
    valueMapper: (value) => value.value,
    nameMapper: (value) => switch (value) {
      PoolCategory.series => 'Series',
      PoolCategory.collection => 'Collection',
    },
    undefinedOption: const EnumFilterNullTagValue(),
  );

  static final orderFilter = EnumFilterTag<PoolOrder>(
    tag: 'search[order]',
    name: 'Sort by',
    values: PoolOrder.values,
    valueMapper: (value) => value.value,
    nameMapper: (value) => switch (value) {
      PoolOrder.newest => 'Newest first',
      PoolOrder.oldest => 'Oldest first',
      PoolOrder.name => 'Name',
      PoolOrder.created => 'Created',
      PoolOrder.updated => 'Updated',
      PoolOrder.postCount => 'Post count',
    },
  );

  String? get name => getFilter(nameFilter);
  set name(String? value) => setFilter(nameFilter, value);

  String? get description => getFilter(descriptionFilter);
  set description(String? value) => setFilter(descriptionFilter, value);

  String? get creator => getFilter(creatorFilter);
  set creator(String? value) => setFilter(creatorFilter, value);

  bool? get active => getFilterBool(activeFilter);
  set active(bool? value) => setFilterBool(activeFilter, value);

  PoolCategory? get category => getFilterEnum(categoryFilter);
  set category(PoolCategory? value) => setFilterEnum(categoryFilter, value);

  PoolOrder get order => getFilterEnum(orderFilter) ?? PoolOrder.newest;
  set order(PoolOrder value) => setFilterEnum(orderFilter, value);
}
