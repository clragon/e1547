import 'package:e1547/dtext/dtext.dart';

final DTextParser listParser = DTextParser(
  regex: RegExp(r'(?<start>^|\n)(?<dots>\*+) '),
  tranformer: (context, match, state) => parseDText(
    context,
    '${match.namedGroup('start')!}${'  ' * (match.namedGroup('dots')!.length - 1)}• ',
    state,
  ),
);
