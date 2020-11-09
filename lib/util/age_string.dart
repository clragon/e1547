String getAge(DateTime date) {
  Duration duration = DateTime.now().difference(date.toLocal());

  List<int> periods = [
    1,
    60,
    3600,
    86400,
    604800,
    2419200,
    29030400,
  ];

  int ago;
  String measurement;
  for (int period = 0; period <= periods.length; period++) {
    if (period == periods.length || duration.inSeconds < periods[period]) {
      if (period != 0) {
        ago = (duration.inSeconds / periods[period - 1]).round();
      } else {
        ago = duration.inSeconds;
      }
      bool single = (ago == 1);
      switch (periods[period - 1] ?? 1) {
        case 1:
          measurement = single ? 'second' : 'seconds';
          break;
        case 60:
          measurement = single ? 'minute' : 'minutes';
          break;
        case 3600:
          measurement = single ? 'hour' : 'hours';
          break;
        case 86400:
          measurement = single ? 'day' : 'days';
          break;
        case 604800:
          measurement = single ? 'week' : 'weeks';
          break;
        case 2419200:
          measurement = single ? 'month' : 'months';
          break;
        case 29030400:
          measurement = single ? 'year' : 'years';
          break;
      }
      break;
    }
  }
  return '$ago $measurement ago';
}
