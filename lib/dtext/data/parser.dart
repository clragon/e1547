import 'package:e1547/dtext/dtext.dart';
import 'package:flutter/material.dart';

typedef DTextTransformer = DTextParserResult? Function(
    BuildContext context, RegExpMatch match, TextState state);

class DTextParser {
  final RegExp regex;
  final DTextTransformer tranformer;

  const DTextParser.builder({required this.regex, required this.tranformer});

  factory DTextParser({
    required RegExp regex,
    required InlineSpan Function(
      BuildContext context,
      RegExpMatch match,
      TextState state,
    )
        tranformer,
  }) =>
      DTextParser.builder(
        regex: regex,
        tranformer: (context, match, state) => DTextParserResult(
          span: tranformer(context, match, state),
          text: match.after,
          state: state,
        ),
      );
}

class DTextParserResult {
  final InlineSpan span;
  final String text;
  final TextState state;

  const DTextParserResult({
    required this.span,
    required this.text,
    required this.state,
  });
}

extension Stringing on RegExpMatch {
  String get before => input.substring(0, start);
  String get between => input.substring(start, end);
  String get after => input.substring(end, input.length);
}
