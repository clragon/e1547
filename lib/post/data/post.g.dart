// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PostImpl _$$PostImplFromJson(Map<String, dynamic> json) => _$PostImpl(
  id: (json['id'] as num).toInt(),
  file: json['file'] as String?,
  sample: json['sample'] as String?,
  preview: json['preview'] as String?,
  width: (json['width'] as num).toInt(),
  height: (json['height'] as num).toInt(),
  ext: json['ext'] as String,
  size: (json['size'] as num).toInt(),
  variants: (json['variants'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String?),
  ),
  tags: (json['tags'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
  ),
  uploaderId: (json['uploader_id'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  vote: VoteInfo.fromJson(json['vote'] as Map<String, dynamic>),
  isDeleted: json['is_deleted'] as bool,
  rating: $enumDecode(_$RatingEnumMap, json['rating']),
  favCount: (json['fav_count'] as num).toInt(),
  isFavorited: json['is_favorited'] as bool,
  commentCount: (json['comment_count'] as num).toInt(),
  description: json['description'] as String,
  sources: (json['sources'] as List<dynamic>).map((e) => e as String).toList(),
  pools: (json['pools'] as List<dynamic>?)
      ?.map((e) => (e as num).toInt())
      .toList(),
  relationships: Relationships.fromJson(json['relationships']),
);

Map<String, dynamic> _$$PostImplToJson(_$PostImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'file': instance.file,
      'sample': instance.sample,
      'preview': instance.preview,
      'width': instance.width,
      'height': instance.height,
      'ext': instance.ext,
      'size': instance.size,
      'variants': instance.variants,
      'tags': instance.tags,
      'uploader_id': instance.uploaderId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'vote': instance.vote,
      'is_deleted': instance.isDeleted,
      'rating': _$RatingEnumMap[instance.rating]!,
      'fav_count': instance.favCount,
      'is_favorited': instance.isFavorited,
      'comment_count': instance.commentCount,
      'description': instance.description,
      'sources': instance.sources,
      'pools': instance.pools,
      'relationships': instance.relationships,
    };

const _$RatingEnumMap = {Rating.s: 's', Rating.q: 'q', Rating.e: 'e'};

_$RelationshipsImpl _$$RelationshipsImplFromJson(Map<String, dynamic> json) =>
    _$RelationshipsImpl(
      parentId: (json['parent_id'] as num?)?.toInt(),
      hasChildren: json['has_children'] as bool,
      hasActiveChildren: json['has_active_children'] as bool?,
      children: (json['children'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$$RelationshipsImplToJson(_$RelationshipsImpl instance) =>
    <String, dynamic>{
      'parent_id': instance.parentId,
      'has_children': instance.hasChildren,
      'has_active_children': instance.hasActiveChildren,
      'children': instance.children,
    };
