import 'package:e1547/markup/markup.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
abstract class DTextParser {
  const DTextParser();

  RegExp get regex;

  DTextParserResult? transform(
    BuildContext context,
    RegExpMatch match,
    TextStateStack state,
  );
}

@immutable
abstract class SpanDTextParser extends DTextParser {
  const SpanDTextParser();

  @override
  @nonVirtual
  DTextParserResult? transform(
    BuildContext context,
    RegExpMatch match,
    TextStateStack state,
  ) =>
      DTextParserResult(
        span: transformSpan(context, match, state),
        text: match.after,
        state: state,
      );

  InlineSpan transformSpan(
    BuildContext context,
    RegExpMatch match,
    TextStateStack state,
  );
}

@immutable
class DTextParserResult {
  const DTextParserResult({
    required this.span,
    required this.text,
    required this.state,
  });

  final InlineSpan span;
  final String text;
  final TextStateStack state;
}

extension RegExpMatchExtraction on RegExpMatch {
  String get before => input.substring(0, start);
  String get between => input.substring(start, end);
  String get after => input.substring(end, input.length);
}
