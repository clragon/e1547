import 'package:deep_pick/deep_pick.dart';
import 'package:e1547/interface/interface.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.freezed.dart';
part 'post.g.dart';

@freezed
class Post with _$Post {
  const factory Post({
    required int id,
    required String? file,
    required String? sample,
    required String? preview,
    required int width,
    required int height,
    required String ext,
    required int size,
    required Map<String, List<String>> tags,
    required int uploaderId,
    required DateTime createdAt,
    required DateTime? updatedAt,
    required VoteInfo vote,
    required bool isDeleted,
    required Rating rating,
    required int favCount, // turn into class with bool isFavorited?
    required bool isFavorited,
    required int commentCount,
    required String description,
    required List<String> sources,
    required List<int> pools,
    required Relationships relationships,
  }) = _Post;

  factory Post.fromJson(dynamic json) => _$PostFromJson(json);
}

@JsonEnum()
enum Rating { s, q, e }

@freezed
class Relationships with _$Relationships {
  const factory Relationships({
    required int? parentId,
    required bool hasChildren,
    required bool hasActiveChildren,
    required List<int> children,
  }) = _Relationships;

  factory Relationships.fromJson(dynamic json) => _$RelationshipsFromJson(json);
}

extension E621Post on Post {
  static Post fromJson(dynamic json) => pick(json).letOrThrow(
        (pick) => Post(
          id: pick('id').asIntOrThrow(),
          file: pick('file').letOrThrow((pick) => pick('url').asStringOrNull()),
          sample:
              pick('sample').letOrThrow((pick) => pick('url').asStringOrNull()),
          preview: pick('preview')
              .letOrThrow((pick) => pick('url').asStringOrNull()),
          width:
              pick('file').letOrThrow((pick) => pick('width').asIntOrThrow()),
          height:
              pick('file').letOrThrow((pick) => pick('height').asIntOrThrow()),
          ext: pick('file').letOrThrow((pick) => pick('ext').asStringOrThrow()),
          size: pick('file').letOrThrow((pick) => pick('size').asIntOrThrow()),
          tags: pick('tags').letOrThrow(
            (pick) => pick.asMapOrThrow<String, List<dynamic>>().map(
                  (key, value) => MapEntry(key, List.from(value)),
                ),
          ),
          uploaderId: pick('uploader_id').asIntOrThrow(),
          createdAt: pick('created_at').asDateTimeOrThrow(),
          updatedAt: pick('updated_at').asDateTimeOrThrow(),
          vote: VoteInfo(
            score: pick('score')
                .letOrThrow((pick) => pick('total').asIntOrThrow()),
          ),
          isDeleted: pick('flags')
              .letOrThrow((pick) => pick('deleted').asBoolOrThrow()),
          rating: pick('rating').letOrThrow(
              (pick) => Rating.values.asNameMap()[pick.asString()]!),
          favCount: pick('fav_count').asIntOrThrow(),
          isFavorited: pick('is_favorited').asBoolOrThrow(),
          commentCount: pick('comment_count').asIntOrThrow(),
          description: pick('description').asStringOrThrow(),
          sources:
              pick('sources').asListOrThrow((pick) => pick.asStringOrThrow()),
          pools: pick('pools').asListOrThrow((pick) => pick.asIntOrThrow()),
          relationships: pick('relationships').letOrThrow((pick) =>
              Relationships.fromJson(pick.asMapOrThrow<String, dynamic>())),
        ),
      );
}
