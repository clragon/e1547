enum MessageWarning {
  warning,
  record,
  ban;

  int get id {
    switch (this) {
      case warning:
        return 0;
      case record:
        return 1;
      case ban:
        return 2;
      default:
        throw ArgumentError('Invalid MessageWarning when fetching id');
    }
  }

  static MessageWarning byId(int id) => values.firstWhere((e) => e.id == id);

  String get message {
    switch (this) {
      case MessageWarning.warning:
        return 'User received a warning for this message';
      case MessageWarning.record:
        return 'User received a record for this message';
      case MessageWarning.ban:
        return 'User was banned for this message';
    }
  }
}
