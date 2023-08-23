import 'package:e1547/dtext/dtext.dart';
import 'package:flutter/material.dart';

class DTextListParser extends SpanDTextParser {
  @override
  RegExp get regex => RegExp(r'(?<start>^|\n)(?<dots>\*+) ');

  @override
  InlineSpan transformSpan(
    BuildContext context,
    RegExpMatch match,
    TextStateStack state,
  ) =>
      parseDText(
        context,
        '${match.namedGroup('start')!}${'  ' * (match.namedGroup('dots')!.length - 1)}• ',
        state,
      );
}
