import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:intl/intl.dart';

// TODO: we need something like this for other services too
extension type HistoryQuery._(QueryMap self) implements QueryMap {
  factory HistoryQuery({
    DateTime? date,
    String? link,
    String? title,
    String? subtitle,
    List<HistoryCategory>? categories,
    List<HistoryType>? types,
  }) {
    return HistoryQuery._(
      {
        'search[date]': date != null ? _dateFormat.format(date) : null,
        'search[link]': link,
        'search[title]': title,
        'search[subtitle]': subtitle,
        'search[category]': categories?.map((e) => e.name).join(','),
        'search[type]': types?.map((e) => e.name).join(','),
      }.toQuery(),
    );
  }

  HistoryQuery.from(QueryMap map) : this._(map);

  static HistoryQuery? maybeFrom(QueryMap? map) {
    if (map == null) return null;
    return HistoryQuery.from(map);
  }

  HistoryQuery copy() => HistoryQuery.from(Map.of(self));

  static DateFormat get _dateFormat => DateFormat('yyyy-MM-dd');

  DateTime? get date {
    try {
      return _dateFormat.parse(self['search[date]'] ?? '');
    } on FormatException {
      return null;
    }
  }

  set date(DateTime? value) => setOrRemove(
    'search[date]',
    value != null ? _dateFormat.format(value) : null,
  );

  String? get link => self['search[link]'];

  set link(String? value) => setOrRemove('search[link]', value);

  String? get title => self['search[title]'];

  set title(String? value) => setOrRemove('search[title]', value);

  String? get subtitle => self['search[subtitle]'];

  set subtitle(String? value) => setOrRemove('search[subtitle]', value);

  Set<HistoryCategory>? get categories => self['search[category]']
      ?.split(',')
      .map((e) => HistoryCategory.values.asNameMap()[e])
      .whereType<HistoryCategory>()
      .toSet();

  set categories(Set<HistoryCategory>? value) =>
      setOrRemove('search[category]', value?.map((e) => e.name).join(','));

  Set<HistoryType>? get types => self['search[type]']
      ?.split(',')
      .map((e) => HistoryType.values.asNameMap()[e])
      .whereType<HistoryType>()
      .toSet();

  set types(Set<HistoryType>? value) =>
      setOrRemove('search[type]', value?.map((e) => e.name).join(','));
}
