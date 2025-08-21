import 'package:collection/collection.dart';
import 'package:e1547/comment/comment.dart';
import 'package:e1547/domain/domain.dart';
import 'package:e1547/query/query.dart';

import 'package:e1547/tag/tag.dart';

enum CommentGroupBy { post, comment }

enum CommentOrder { id_desc, id_asc }

class CommentFilter extends FilterController<Comment> {
  CommentFilter({ProtoMap? value, required this.domain})
    : super(value?.toQuery());

  final Domain domain;

  static const keys = (
    groupBy: 'group_by',
    postId: 'search[post_id]',
    body: 'search[body_matches]',
    creator: 'search[creator_name]',
    postTags: 'search[post_tags_match]',
    order: 'search[order]',
  );

  CommentGroupBy get groupBy =>
      getEnum(keys.groupBy, CommentGroupBy.values) ?? CommentGroupBy.post;
  set groupBy(CommentGroupBy value) => set(keys.groupBy, value);

  int? get postId => get(keys.postId);
  set postId(int? value) => set(keys.postId, value);

  String? get body => get(keys.body);
  set body(String? value) => set(keys.body, value);

  String? get creator => get(keys.creator);
  set creator(String? value) => set(keys.creator, value);

  List<String>? get postTags => TagMap(get<String>(keys.postTags)).tags;
  set postTags(List<String>? value) => set(keys.postTags, value?.join(' '));

  CommentOrder get order =>
      getEnum(keys.order, CommentOrder.values) ?? CommentOrder.id_desc;
  set order(CommentOrder value) => set(keys.order, value);

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
