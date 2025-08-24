import 'package:e1547/query/query.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/topic/topic.dart';

enum TopicOrder {
  sticky('sticky'),
  newest('id_desc'),
  oldest('id_asc');

  const TopicOrder(this.value);

  final String value;
}

enum TopicCategory {
  general(1),
  siteBugReportsAndFeatureRequests(11),
  tagWikiProjectsAndQuestions(10),
  tagAliasAndImplicationSuggestions(2),
  artTalk(3),
  offTopic(5),
  e621ToolsAndApplications(9);

  const TopicCategory(this.id);

  final int id;
}

class TopicFilter extends FilterController<Topic> {
  TopicFilter({ProtoMap? value})
    : super({orderFilter.tag: TopicOrder.sticky, ...?value}.toQuery());

  static const titleFilter = TextFilterTag(
    tag: 'search[title_matches]',
    name: 'Title contains',
  );

  static final categoryIdFilter = EnumFilterTag<TopicCategory>(
    tag: 'search[category_id]',
    name: 'Category',
    values: TopicCategory.values,
    valueMapper: (value) => value.id.toString(),
    nameMapper: (value) => switch (value) {
      TopicCategory.general => 'General',
      TopicCategory.siteBugReportsAndFeatureRequests =>
        'Site Bug Reports & Feature Requests',
      TopicCategory.tagWikiProjectsAndQuestions =>
        'Tag/Wiki Projects and Questions',
      TopicCategory.tagAliasAndImplicationSuggestions =>
        'Tag Alias and Implication Suggestions',
      TopicCategory.artTalk => 'Art Talk',
      TopicCategory.offTopic => 'Off Topic',
      TopicCategory.e621ToolsAndApplications => 'e621 Tools and Applications',
    },
    undefinedOption: const EnumFilterNullTagValue(),
  );

  static final orderFilter = EnumFilterTag<TopicOrder>(
    tag: 'search[order]',
    name: 'Sort by',
    values: TopicOrder.values,
    valueMapper: (value) => value.value,
    nameMapper: (value) => switch (value) {
      TopicOrder.sticky => 'Default',
      TopicOrder.newest => 'Newest first',
      TopicOrder.oldest => 'Oldest first',
    },
  );

  static const stickyFilter = BooleanFilterTag(
    tag: 'search[is_sticky]',
    name: 'Sticky',
    description: 'Is sticky',
    tristate: true,
  );

  static const lockedFilter = BooleanFilterTag(
    tag: 'search[is_locked]',
    name: 'Locked',
    description: 'Is locked',
    tristate: true,
  );

  // TODO: remove this and implement fetching AIBUR inside dtext
  static const hideTagEditingFilter = BooleanFilterTag(
    tag: 'hide_tag_editing',
    name: 'Hide tag edits',
    description: 'Hide tag editing topics',
    tristate: true,
  );

  @override
  QueryMap get request => value.select([
    titleFilter.tag,
    categoryIdFilter.tag,
    orderFilter.tag,
    stickyFilter.tag,
    lockedFilter.tag,
    // hideTagEditingFilter is for local filtering only
  ]);

  String? get title => getFilter(titleFilter);
  set title(String? value) => setFilter(titleFilter, value);

  TopicCategory? get categoryId => getFilterEnum(categoryIdFilter);
  set categoryId(TopicCategory? value) =>
      setFilterEnum(categoryIdFilter, value);

  TopicOrder get order => getFilterEnum(orderFilter) ?? TopicOrder.newest;
  set order(TopicOrder value) => setFilterEnum(orderFilter, value);

  bool? get sticky => getFilterBool(stickyFilter);
  set sticky(bool? value) => setFilterBool(stickyFilter, value);

  bool? get locked => getFilterBool(lockedFilter);
  set locked(bool? value) => setFilterBool(lockedFilter, value);

  bool get hideTagEditing => getFilterBool(hideTagEditingFilter) ?? true;
  set hideTagEditing(bool value) => setFilterBool(hideTagEditingFilter, value);

  @override
  List<List<Topic>> filter(List<List<Topic>> items) => items
      .map(
        (page) => page
            .where(
              (topic) =>
                  !hideTagEditing ||
                  topic.categoryId !=
                      TopicCategory.tagAliasAndImplicationSuggestions.id,
            )
            .toList(),
      )
      .toList();
}
