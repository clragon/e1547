import 'package:e1547/history/history.dart';
import 'package:e1547/tag/tag.dart';

extension Naming on TagHistoryEntry {
  String get name => tagToTitle(alias ?? tags);
}
