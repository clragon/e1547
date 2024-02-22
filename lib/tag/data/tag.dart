import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag.freezed.dart';
part 'tag.g.dart';

@freezed
class Tag with _$Tag {
  // TODO: remove useless fields
  const factory Tag({
    required int id,
    required String name,
    required int postCount,
    required int category,
  }) = _Tag;

  factory Tag.fromJson(dynamic json) => _$TagFromJson(json);
}
