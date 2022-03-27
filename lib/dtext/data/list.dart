import 'package:e1547/dtext/dtext.dart';

final DTextParser listParser = DTextParser(
  regex: RegExp(r'(^|\n)(?<dots>\*+) '),
  tranformer: (context, match, state) => parseDText(
    context,
    '\n' + '  ' * ('*'.allMatches(match.between).length - 1) + '• ',
    state,
  ),
);
