import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

Widget textWrap(TextSpan span) {
  return RichText(
    text: span,
  );
}

TextSpan spanWrap(BuildContext context, String msg, Map<String, bool> states,
    {Function() onTap}) {
  msg = msg.replaceAll('\\[', '[');
  msg = msg.replaceAll('\\]', ']');

  msg = msg.replaceAllMapped(RegExp(r'(\r\n){4,}'), (lines) => '\n');

  return TextSpan(
    text: msg,
    recognizer: TapGestureRecognizer()..onTap = onTap,
    style: TextStyle(
      color: states['link']
          ? Colors.blue[400]
          : states['dark']
              ? Colors.grey[600]
              : Theme.of(context).textTheme.bodyText2.color,
      fontWeight: states['bold'] ? FontWeight.bold : FontWeight.normal,
      fontStyle: states['italic'] ? FontStyle.italic : FontStyle.normal,
      fontSize: states['headline'] ? 18 : null,
      decoration: TextDecoration.combine([
        states['strike'] ? TextDecoration.lineThrough : TextDecoration.none,
        states['underline'] ? TextDecoration.underline : TextDecoration.none,
      ]),
    ),
  );
}
