import 'package:e1547/comment/comment.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/tag/tag.dart';

enum CommentGroupBy { post, comment }

enum CommentOrder {
  newest('id_desc'),
  oldest('id_asc');

  const CommentOrder(this.value);

  final String value;
}

class CommentParams extends ParamsController<Comment> {
  CommentParams({ProtoMap? value}) : super(value?.toQuery());

  static final groupByFilter = EnumFilterTag<CommentGroupBy>(
    tag: 'group_by',
    name: 'Group by',
    values: CommentGroupBy.values,
    nameMapper: (value) => switch (value) {
      CommentGroupBy.post => 'Post',
      CommentGroupBy.comment => 'Comment',
    },
  );

  static const postIdFilter = NumberFilterTag(
    tag: 'search[post_id]',
    name: 'Post ID',
  );

  static const bodyFilter = TextFilterTag(
    tag: 'search[body_matches]',
    name: 'Body contains',
  );

  static const creatorFilter = TextFilterTag(
    tag: 'search[creator_name]',
    name: 'Creator',
  );

  static const postTagsFilter = TextFilterTag(
    tag: 'search[post_tags_match]',
    name: 'Post tags',
  );

  static final orderFilter = EnumFilterTag<CommentOrder>(
    tag: 'search[order]',
    name: 'Sort by',
    values: CommentOrder.values,
    valueMapper: (value) => value.value,
    nameMapper: (value) => switch (value) {
      CommentOrder.newest => 'Newest first',
      CommentOrder.oldest => 'Oldest first',
    },
  );

  CommentGroupBy get groupBy =>
      getFilterEnum(groupByFilter) ?? CommentGroupBy.post;
  set groupBy(CommentGroupBy value) => setFilterEnum(groupByFilter, value);

  int? get postId => getFilter(postIdFilter);
  set postId(int? value) => setFilter(postIdFilter, value);

  String? get body => getFilter(bodyFilter);
  set body(String? value) => setFilter(bodyFilter, value);

  String? get creator => getFilter(creatorFilter);
  set creator(String? value) => setFilter(creatorFilter, value);

  List<String>? get postTags => TagMap(getFilter<String>(postTagsFilter)).tags;
  set postTags(List<String>? value) =>
      setFilter(postTagsFilter, value?.join(' '));

  CommentOrder get order => getFilterEnum(orderFilter) ?? CommentOrder.newest;
  set order(CommentOrder value) => setFilterEnum(orderFilter, value);
}
