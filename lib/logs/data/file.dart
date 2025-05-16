import 'package:e1547/interface/interface.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

final DateFormat logFileDateFormat = DateFormat('yyyy-MM-dd-HH-mm-ss-SSS');

class LogFileInfo {
  LogFileInfo({required this.path, required this.date, required this.type});

  factory LogFileInfo.parse(String path) {
    String raw = basenameWithoutExtension(path);
    String? type = extension(raw);
    if (type.isNotEmpty) {
      type = type.substring(1);
      raw = basenameWithoutExtension(raw);
    } else {
      type = null;
    }
    DateTime date = logFileDateFormat.parse(raw);
    return LogFileInfo(path: path, date: date, type: type);
  }

  final String path;
  final DateTime date;
  final String? type;

  @override
  String toString() =>
      '${DateFormatting.dateTime(date)} ${type != null ? ' ($type)' : ''}';
}
