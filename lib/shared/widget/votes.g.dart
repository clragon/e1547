// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'votes.dart';

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

_VoteResult _$VoteResultFromJson(Map<String, dynamic> json) => _VoteResult(
  score: (json['score'] as num).toInt(),
  ourScore: (json['our_score'] as num).toInt(),
);

Map<String, dynamic> _$VoteResultToJson(_VoteResult instance) =>
    <String, dynamic>{'score': instance.score, 'our_score': instance.ourScore};
