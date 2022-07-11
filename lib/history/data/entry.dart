import 'package:freezed_annotation/freezed_annotation.dart';

part 'entry.freezed.dart';
part 'entry.g.dart';

@freezed
class History with _$History {
  const factory History({
    required int id,
    required DateTime visitedAt,
    required String link,
    required List<String> thumbnails,
    required String? title,
    required String? subtitle,
  }) = _History;

  factory History.fromJson(Map<String, dynamic> json) =>
      _$HistoryFromJson(json);
}

@freezed
class HistoryRequest with _$HistoryRequest {
  const factory HistoryRequest({
    required DateTime visitedAt,
    required String link,
    @Default([]) List<String> thumbnails,
    String? title,
    String? subtitle,
  }) = _HistoryRequest;

  factory HistoryRequest.fromJson(Map<String, dynamic> json) =>
      _$HistoryRequestFromJson(json);
}
