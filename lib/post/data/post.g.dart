// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PostImpl _$$PostImplFromJson(Map<String, dynamic> json) => _$PostImpl(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      fileRaw: PostSourceFile.fromJson(json['file']),
      preview: PostPreviewFile.fromJson(json['preview']),
      sample: PostSampleFile.fromJson(json['sample']),
      score: Score.fromJson(json['score']),
      tags: (json['tags'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
      lockedTags: (json['locked_tags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      changeSeq: json['change_seq'] as int?,
      flags: Flags.fromJson(json['flags']),
      rating: $enumDecode(_$RatingEnumMap, json['rating']),
      favCount: json['fav_count'] as int,
      sources:
          (json['sources'] as List<dynamic>).map((e) => e as String).toList(),
      pools: (json['pools'] as List<dynamic>).map((e) => e as int).toList(),
      relationships: Relationships.fromJson(json['relationships']),
      approverId: json['approver_id'] as int?,
      uploaderId: json['uploader_id'] as int,
      description: json['description'] as String,
      commentCount: json['comment_count'] as int,
      isFavorited: json['is_favorited'] as bool,
      hasNotes: json['has_notes'] as bool,
      duration: (json['duration'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$PostImplToJson(_$PostImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'file': instance.fileRaw,
      'preview': instance.preview,
      'sample': instance.sample,
      'score': instance.score,
      'tags': instance.tags,
      'locked_tags': instance.lockedTags,
      'change_seq': instance.changeSeq,
      'flags': instance.flags,
      'rating': _$RatingEnumMap[instance.rating]!,
      'fav_count': instance.favCount,
      'sources': instance.sources,
      'pools': instance.pools,
      'relationships': instance.relationships,
      'approver_id': instance.approverId,
      'uploader_id': instance.uploaderId,
      'description': instance.description,
      'comment_count': instance.commentCount,
      'is_favorited': instance.isFavorited,
      'has_notes': instance.hasNotes,
      'duration': instance.duration,
    };

const _$RatingEnumMap = {
  Rating.s: 's',
  Rating.q: 'q',
  Rating.e: 'e',
};

_$PostPreviewFileImpl _$$PostPreviewFileImplFromJson(
        Map<String, dynamic> json) =>
    _$PostPreviewFileImpl(
      width: json['width'] as int,
      height: json['height'] as int,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$$PostPreviewFileImplToJson(
        _$PostPreviewFileImpl instance) =>
    <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'url': instance.url,
    };

_$PostSampleFileImpl _$$PostSampleFileImplFromJson(Map<String, dynamic> json) =>
    _$PostSampleFileImpl(
      has: json['has'] as bool,
      height: json['height'] as int,
      width: json['width'] as int,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$$PostSampleFileImplToJson(
        _$PostSampleFileImpl instance) =>
    <String, dynamic>{
      'has': instance.has,
      'height': instance.height,
      'width': instance.width,
      'url': instance.url,
    };

_$PostSourceFileImpl _$$PostSourceFileImplFromJson(Map<String, dynamic> json) =>
    _$PostSourceFileImpl(
      width: json['width'] as int,
      height: json['height'] as int,
      ext: json['ext'] as String,
      size: json['size'] as int,
      md5: json['md5'] as String,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$$PostSourceFileImplToJson(
        _$PostSourceFileImpl instance) =>
    <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'ext': instance.ext,
      'size': instance.size,
      'md5': instance.md5,
      'url': instance.url,
    };

_$FlagsImpl _$$FlagsImplFromJson(Map<String, dynamic> json) => _$FlagsImpl(
      pending: json['pending'] as bool,
      flagged: json['flagged'] as bool,
      noteLocked: json['note_locked'] as bool,
      statusLocked: json['status_locked'] as bool,
      ratingLocked: json['rating_locked'] as bool,
      deleted: json['deleted'] as bool,
    );

Map<String, dynamic> _$$FlagsImplToJson(_$FlagsImpl instance) =>
    <String, dynamic>{
      'pending': instance.pending,
      'flagged': instance.flagged,
      'note_locked': instance.noteLocked,
      'status_locked': instance.statusLocked,
      'rating_locked': instance.ratingLocked,
      'deleted': instance.deleted,
    };

_$RelationshipsImpl _$$RelationshipsImplFromJson(Map<String, dynamic> json) =>
    _$RelationshipsImpl(
      parentId: json['parent_id'] as int?,
      hasChildren: json['has_children'] as bool,
      hasActiveChildren: json['has_active_children'] as bool,
      children:
          (json['children'] as List<dynamic>).map((e) => e as int).toList(),
    );

Map<String, dynamic> _$$RelationshipsImplToJson(_$RelationshipsImpl instance) =>
    <String, dynamic>{
      'parent_id': instance.parentId,
      'has_children': instance.hasChildren,
      'has_active_children': instance.hasActiveChildren,
      'children': instance.children,
    };

_$ScoreImpl _$$ScoreImplFromJson(Map<String, dynamic> json) => _$ScoreImpl(
      up: json['up'] as int,
      down: json['down'] as int,
      total: json['total'] as int,
    );

Map<String, dynamic> _$$ScoreImplToJson(_$ScoreImpl instance) =>
    <String, dynamic>{
      'up': instance.up,
      'down': instance.down,
      'total': instance.total,
    };
