import 'package:e1547/dtext/dtext.dart';
import 'package:flutter/material.dart';

class DTextHeaderParser extends SpanDTextParser {
  @override
  RegExp get regex =>
      RegExp(r'h(?<size>[1-6])\.\s?(?<name>.*)', caseSensitive: false);

  @override
  InlineSpan transformSpan(
    BuildContext context,
    RegExpMatch match,
    TextStateStack state,
  ) =>
      parseDText(
        context,
        match.namedGroup('name')!,
        state.push(TextStateHeader(int.parse(match.namedGroup('size')!))),
      );
}
