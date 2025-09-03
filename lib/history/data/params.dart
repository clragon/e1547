import 'package:e1547/history/history.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/tag/tag.dart';
import 'package:intl/intl.dart';

class HistoryParams extends ParamsController {
  HistoryParams({ProtoMap? value}) : super(value?.toQuery());

  static const dateFilter = TextFilterTag(tag: 'search[date]', name: 'Date');

  static const linkFilter = TextFilterTag(
    tag: 'search[link]',
    name: 'Link contains',
  );

  static const titleFilter = TextFilterTag(
    tag: 'search[title]',
    name: 'Title contains',
  );

  static const subtitleFilter = TextFilterTag(
    tag: 'search[subtitle]',
    name: 'Subtitle contains',
  );

  static final categoryFilter = MultiEnumFilterTag<HistoryCategory>(
    tag: 'search[category]',
    name: 'Category',
    values: HistoryCategory.values,
    valueMapper: (value) => value.name,
    nameMapper: (value) => switch (value) {
      HistoryCategory.items => 'Items',
      HistoryCategory.searches => 'Searches',
    },
  );

  static final typeFilter = MultiEnumFilterTag<HistoryType>(
    tag: 'search[type]',
    name: 'Type',
    values: HistoryType.values,
    valueMapper: (value) => value.name,
    nameMapper: (value) => switch (value) {
      HistoryType.posts => 'Posts',
      HistoryType.pools => 'Pools',
      HistoryType.topics => 'Topics',
      HistoryType.users => 'Users',
      HistoryType.wikis => 'Wikis',
    },
  );

  static DateFormat get _dateFormat => DateFormat('yyyy-MM-dd');

  DateTime? get date {
    final dateStr = getFilter<String>(dateFilter);
    if (dateStr == null) return null;
    try {
      return _dateFormat.parse(dateStr);
    } on FormatException {
      return null;
    }
  }

  set date(DateTime? value) =>
      setFilter(dateFilter, value != null ? _dateFormat.format(value) : null);

  String? get link => getFilter(linkFilter);
  set link(String? value) => setFilter(linkFilter, value);

  String? get title => getFilter(titleFilter);
  set title(String? value) => setFilter(titleFilter, value);

  String? get subtitle => getFilter(subtitleFilter);
  set subtitle(String? value) => setFilter(subtitleFilter, value);

  Set<HistoryCategory>? get categories => getFilterEnumSet(categoryFilter);
  set categories(Set<HistoryCategory>? value) =>
      setFilterEnumSet(categoryFilter, value);

  Set<HistoryType>? get types => getFilterEnumSet(typeFilter);
  set types(Set<HistoryType>? value) => setFilterEnumSet(typeFilter, value);
}
