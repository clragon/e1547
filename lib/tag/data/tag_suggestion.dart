import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tag_suggestion.g.dart';

@JsonSerializable()
@CopyWith()
class TagSuggestion {
  TagSuggestion({
    required this.id,
    required this.name,
    required this.postCount,
    required this.category,
    required this.antecedentName,
  });

  final int id;
  final String name;
  final int postCount;
  final int category;
  final String? antecedentName;

  factory TagSuggestion.fromJson(Map<String, dynamic> json) =>
      _$TagSuggestionFromJson(json);

  Map<String, dynamic> toJson() => _$TagSuggestionToJson(this);
}
