// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VoteInfo _$VoteInfoFromJson(Map<String, dynamic> json) => _VoteInfo(
  score: (json['score'] as num).toInt(),
  status:
      $enumDecodeNullable(_$VoteStatusEnumMap, json['status']) ??
      VoteStatus.unknown,
);

Map<String, dynamic> _$VoteInfoToJson(_VoteInfo instance) => <String, dynamic>{
  'score': instance.score,
  'status': _$VoteStatusEnumMap[instance.status]!,
};

const _$VoteStatusEnumMap = {
  VoteStatus.upvoted: 'upvoted',
  VoteStatus.unknown: 'unknown',
  VoteStatus.downvoted: 'downvoted',
};
