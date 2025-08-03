import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag.freezed.dart';
part 'tag.g.dart';

@freezed
abstract class Tag with _$Tag {
  const factory Tag({
    required int id,
    required String name,
    required int count,
    required int category,
  }) = _Tag;

  factory Tag.fromJson(dynamic json) => _$TagFromJson(json);
}
