import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

enum PostOrder {
  newest('new'),
  score('score'),
  favcount('favcount'),
  rank('rank'),
  random('random');

  const PostOrder(this.value);

  final String value;
}

class PostParams extends ParamsController {
  PostParams({ProtoMap? value}) : super(value?.toQuery());

  static final tagsFilter = NestedFilterTag(
    tag: 'tags',
    decode: TagMap.new,
    encode: (value) => TagMap.from(value).toString(),
    filters: [
      const NumberRangeFilterTag(
        tag: 'score',
        name: 'Score',
        min: 0,
        max: 100,
        division: 10,
        initial: NumberRange(
          20,
          comparison: NumberComparison.greaterThanOrEqual,
        ),
        icon: Icon(Icons.arrow_upward),
      ),
      const NumberRangeFilterTag(
        tag: 'favcount',
        name: 'Favorite count',
        min: 0,
        max: 100,
        division: 10,
        initial: NumberRange(
          20,
          comparison: NumberComparison.greaterThanOrEqual,
        ),
        icon: Icon(Icons.favorite),
      ),
      EnumFilterTag<PostOrder>(
        tag: 'order',
        name: 'Sort by',
        values: PostOrder.values,
        valueMapper: (value) => value.value,
        nameMapper: (value) => switch (value) {
          PostOrder.newest => 'New',
          PostOrder.score => 'Score',
          PostOrder.favcount => 'Favorites',
          PostOrder.rank => 'Rank',
          PostOrder.random => 'Random',
        },
        undefinedOption: const EnumFilterNullTagValue(name: 'Default'),
        icon: const Icon(Icons.sort),
      ),
      EnumFilterTag(
        tag: 'rating',
        name: 'Rating',
        values: Rating.values,
        valueMapper: (value) => value.name,
        nameMapper: (value) => switch (value) {
          Rating.s => 'Safe',
          Rating.q => 'Questionable',
          Rating.e => 'Explicit',
        },
        undefinedOption: const EnumFilterNullTagValue(name: 'All'),
        icon: const Icon(Icons.question_mark),
      ),
      const BooleanFilterTag(
        tag: 'inpool',
        name: 'Pool',
        description: 'Has pool',
        tristate: true,
      ),
      const BooleanFilterTag(
        tag: 'ischild',
        name: 'Child',
        description: 'Is child post',
        tristate: true,
      ),
      const BooleanFilterTag(
        tag: 'isparent',
        name: 'Parent',
        description: 'Is parent post',
        tristate: true,
      ),
      const ChoiceFilterTag(
        tag: 'date',
        name: 'Upload date',

        options: [
          ChoiceFilterTagValue(value: null, name: 'All'),
          ChoiceFilterTagValue(value: 'day', name: 'Last day'),
          ChoiceFilterTagValue(value: 'week', name: 'Last week'),
          ChoiceFilterTagValue(value: 'month', name: 'Last Month'),
          ChoiceFilterTagValue(value: 'year', name: 'Last Year'),
        ],
        icon: Icon(Icons.date_range),
      ),
      const ChoiceFilterTag(
        tag: 'status',
        name: 'Status',
        options: [
          ChoiceFilterTagValue(value: null, name: 'Default'),
          ChoiceFilterTagValue(value: 'active', name: 'Active'),
          ChoiceFilterTagValue(value: 'pending', name: 'Pending'),
          ChoiceFilterTagValue(value: 'deleted', name: 'Deleted'),
          ChoiceFilterTagValue(value: 'flagged', name: 'Flagged'),
          ChoiceFilterTagValue(value: 'any', name: 'Any'),
        ],
        icon: Icon(Icons.help),
      ),
    ],
  );

  String? get tags => get<String>('tags');
  set tags(String? value) => set('tags', value);

  TagMap get _tagMap => TagMap(tags);

  String? _getNestedTag(String key) => _tagMap[key];

  void _setNestedTag(String key, String? value) {
    final tagMap = _tagMap;
    if (value == null) {
      tagMap.remove(key);
    } else {
      tagMap[key] = value;
    }
    tags = tagMap.toString();
  }

  NumberRange? get score => NumberRange.tryParse(_getNestedTag('score') ?? '');
  set score(NumberRange? value) => _setNestedTag('score', value?.toString());

  NumberRange? get favcount =>
      NumberRange.tryParse(_getNestedTag('favcount') ?? '');
  set favcount(NumberRange? value) =>
      _setNestedTag('favcount', value?.toString());

  PostOrder? get order {
    final value = _getNestedTag('order');
    if (value == null) return null;
    return PostOrder.values.where((e) => e.value == value).firstOrNull;
  }

  set order(PostOrder? value) => _setNestedTag('order', value?.value);

  String? get rating => _getNestedTag('rating');
  set rating(String? value) => _setNestedTag('rating', value);

  bool? get inpool {
    final value = _getNestedTag('inpool');
    if (value == null) return null;
    return value == 'true';
  }

  set inpool(bool? value) => _setNestedTag(
    'inpool',
    value == null ? null : (value ? 'true' : 'false'),
  );

  bool? get ischild {
    final value = _getNestedTag('ischild');
    if (value == null) return null;
    return value == 'true';
  }

  set ischild(bool? value) => _setNestedTag(
    'ischild',
    value == null ? null : (value ? 'true' : 'false'),
  );

  bool? get isparent {
    final value = _getNestedTag('isparent');
    if (value == null) return null;
    return value == 'true';
  }

  set isparent(bool? value) => _setNestedTag(
    'isparent',
    value == null ? null : (value ? 'true' : 'false'),
  );

  String? get date => _getNestedTag('date');
  set date(String? value) => _setNestedTag('date', value);

  String? get status => _getNestedTag('status');
  set status(String? value) => _setNestedTag('status', value);

  void addTag(String tag) => tags = (_tagMap..add(tag)).toString();

  void removeTag(String tag) => tags = (_tagMap..remove(tag)).toString();

  void subtractTag(String tag) => addTag('-$tag');

  bool hasTag(String tag) => _tagMap.containsKey(tag);
}
