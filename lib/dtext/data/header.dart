import 'package:e1547/dtext/dtext.dart';

final DTextParser headerParser = DTextParser(
  regex: RegExp(r'h(?<size>[1-6])\.\s?(?<name>.*)', caseSensitive: false),
  tranformer: (context, match, state) => parseDText(
    context,
    match.namedGroup('name')!,
    state.push(TextStateHeader(int.parse(match.namedGroup('size')!))),
  ),
);
