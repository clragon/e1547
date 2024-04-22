import 'package:freezed_annotation/freezed_annotation.dart';

part 'history.freezed.dart';
part 'history.g.dart';

@freezed
class History with _$History {
  const factory History({
    required int id,
    required DateTime visitedAt,
    required String link,
    required HistoryCategory category,
    required HistoryType type,
    required String? title,
    required String? subtitle,
    required List<String> thumbnails,
  }) = _History;

  factory History.fromJson(dynamic json) => _$HistoryFromJson(json);
}

@freezed
class HistoryRequest with _$HistoryRequest {
  const factory HistoryRequest({
    required DateTime visitedAt,
    required String link,
    required HistoryCategory category,
    required HistoryType type,
    String? title,
    String? subtitle,
    @Default([]) List<String> thumbnails,
  }) = _HistoryRequest;

  factory HistoryRequest.fromJson(dynamic json) =>
      _$HistoryRequestFromJson(json);
}

enum HistoryCategory {
  items,
  searches,
}

enum HistoryType {
  posts,
  pools,
  topics,
  users,
  wikis,
}
