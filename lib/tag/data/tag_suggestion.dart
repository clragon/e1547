import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag_suggestion.freezed.dart';
part 'tag_suggestion.g.dart';

@freezed
class TagSuggestion with _$TagSuggestion {
  const factory TagSuggestion({
    required int id,
    required String name,
    required int postCount,
    required int category,
    required String? antecedentName,
  }) = _TagSuggestion;

  factory TagSuggestion.fromJson(Map<String, dynamic> json) =>
      _$TagSuggestionFromJson(json);
}
