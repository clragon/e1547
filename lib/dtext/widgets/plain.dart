import 'package:e1547/dtext/dtext.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

String escape(String text) {
  return text.replaceAll('[', '\\[').replaceAll(']', '\\]');
}

String normalize(String text) {
  return text.replaceAll('\\[', '[').replaceAll('\\]', ']');
}

TextSpan plainText(
    {required BuildContext context,
    required String text,
    required TextState state,
    VoidCallback? onTap}) {
  text = normalize(text);
  text = text.replaceAllMapped(RegExp(r'\n{4,}'), (_) => '\n');

  return TextSpan(
    text: text,
    recognizer: TapGestureRecognizer()..onTap = onTap,
    style: TextStyle(
      color: state.dark
          ? Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.5)
          : state.link
              ? Colors.blue[400]
              : Theme.of(context).textTheme.bodyText1!.color!,
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
