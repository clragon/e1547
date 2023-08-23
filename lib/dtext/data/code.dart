import 'package:e1547/dtext/dtext.dart';
import 'package:flutter/material.dart';

class DTextCodeParser extends SpanDTextParser {
  const DTextCodeParser();

  @override
  RegExp get regex => RegExp(r'`(?<code>(.|\n)*?)`');

  @override
  InlineSpan transformSpan(
    BuildContext context,
    RegExpMatch match,
    TextStateStack state,
  ) =>
      plainText(
        context: context,
        text: match.namedGroup('code')!,
        state: state.push(TextStateInlineCode()),
      );
}
