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
    required Map<TextState, bool> state,
    VoidCallback? onTap}) {
  text = normalize(text);
  text = text.replaceAllMapped(RegExp(r'\n{4,}'), (_) => '\n');

  return TextSpan(
    text: text,
    recognizer: TapGestureRecognizer()..onTap = onTap,
    style: TextStyle(
      color: state[TextState.dark]!
          ? Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.5)
          : state[TextState.link]!
              ? Colors.blue[400]
              : null,
      fontWeight: state[TextState.bold]! ? FontWeight.bold : null,
      fontStyle: state[TextState.italic]! ? FontStyle.italic : null,
      fontSize: state[TextState.header]! ? 18 : null,
      decoration: TextDecoration.combine([
        state[TextState.strikeout]!
            ? TextDecoration.lineThrough
            : TextDecoration.none,
        state[TextState.underline]!
            ? TextDecoration.underline
            : TextDecoration.none,
        state[TextState.overline]!
            ? TextDecoration.overline
            : TextDecoration.none,
      ]),
    ),
  );
}
