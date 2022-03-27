import 'package:e1547/dtext/dtext.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

String escape(String text) {
  return text.replaceAll('[', '\\[').replaceAll(']', '\\]');
}

String normalize(String text) {
  return text.replaceAll('\\[', '[').replaceAll('\\]', ']');
}

TextSpan plainText({
  required BuildContext context,
  required String text,
  required TextState state,
}) {
  text = normalize(text);
  text = text.replaceAllMapped(RegExp(r'\n{4,}'), (_) => '\n');

  return TextSpan(
    text: text,
    recognizer: state.onTap != null
        ? (TapGestureRecognizer()..onTap = state.onTap)
        : null,
    style: TextStyle(
      color: state.link ? Colors.blue[400] : null,
      fontWeight: state.bold ? FontWeight.bold : null,
      fontStyle: state.italic ? FontStyle.italic : null,
      fontSize: state.header ? 18 : null,
      decoration: TextDecoration.combine([
        state.strikeout ? TextDecoration.lineThrough : TextDecoration.none,
        state.underline ? TextDecoration.underline : TextDecoration.none,
        state.overline ? TextDecoration.overline : TextDecoration.none,
      ]),
    ),
  );
}
