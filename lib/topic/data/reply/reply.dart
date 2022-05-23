import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reply.g.dart';

@JsonSerializable()
@CopyWith()
class Reply {
  Reply({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.body,
    required this.creatorId,
    required this.updaterId,
    required this.topicId,
    required this.isHidden,
    required this.warningType,
    required this.warningUserId,
  });

  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String body;
  final int creatorId;
  final int? updaterId;
  final int topicId;
  final bool isHidden;
  final WarningType warningType;
  final int? warningUserId;

  factory Reply.fromJson(Map<String, dynamic> json) => _$ReplyFromJson(json);

  Map<String, dynamic> toJson() => _$ReplyToJson(this);
}

@JsonEnum()
enum WarningType {
  warning,
  record,
  ban,
}
