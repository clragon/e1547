import 'package:e1547/follow/follow.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/tag/tag.dart';

class FollowParams extends ParamsController {
  FollowParams({ProtoMap? value}) : super(value?.toQuery());

  static const tagsFilter = TextFilterTag(
    tag: 'search[tags]',
    name: 'Tags contains',
  );

  static const titleFilter = TextFilterTag(
    tag: 'search[title]',
    name: 'Title contains',
  );

  static final typeFilter = MultiEnumFilterTag<FollowType>(
    tag: 'search[type]',
    name: 'Type',
    values: FollowType.values,
    valueMapper: (value) => value.name,
    nameMapper: (value) => switch (value) {
      FollowType.notify => 'Notify',
      FollowType.update => 'Update',
      FollowType.bookmark => 'Bookmark',
    },
  );

  static const hasUnseenFilter = BooleanFilterTag(
    tag: 'search[has_unseen]',
    name: 'Has unseen',
  );

  String? get tags => getFilter(tagsFilter);
  set tags(String? value) => setFilter(tagsFilter, value);

  String? get title => getFilter(titleFilter);
  set title(String? value) => setFilter(titleFilter, value);

  Set<FollowType>? get types => getFilterEnumSet(typeFilter);
  set types(Set<FollowType>? value) => setFilterEnumSet(typeFilter, value);

  bool? get hasUnseen => getFilterBool(hasUnseenFilter);
  set hasUnseen(bool? value) => setFilterBool(hasUnseenFilter, value);
}
