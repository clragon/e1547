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
    required int? commentCount,
    required bool? hasComments,
    required String description,
    required List<String> sources,
    required List<int>? pools,
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
