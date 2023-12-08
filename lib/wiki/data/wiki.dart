import 'package:freezed_annotation/freezed_annotation.dart';

part 'wiki.freezed.dart';
part 'wiki.g.dart';

@freezed
class Wiki with _$Wiki {
  const factory Wiki({
    required int id,
    required String title,
    required String body,
    required DateTime createdAt,
    DateTime? updatedAt,
    required int categoryId,
    List<String>? otherNames,
    bool? isLocked,
  }) = _Wiki;

  factory Wiki.fromJson(dynamic json) => _$WikiFromJson(json);
}

extension E621Wiki on Wiki {
  static Wiki fromJson(dynamic json) => Wiki.fromJson(json);
}
