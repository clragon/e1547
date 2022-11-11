import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/interface/interface.dart';
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
  required TextStateStack state,
}) {
  text = normalize(text);
  text = text.replaceAllMapped(RegExp(r'\n{4,}'), (_) => '\n');

  SpoilerController spoilerController = context.watch<SpoilerController>();

  TextStateSpoiler? spoiler = state.getClosest();
  TextStateLink? link = state.getClosest();

  bool isSpoilered =
      spoiler != null && spoilerController.isSpoilered(spoiler.text);

  void toggleSpoiler() => spoilerController.toggle(spoiler!.text);

  VoidCallback? onTap;

  if (isSpoilered) {
    onTap = toggleSpoiler;
  } else {
    onTap = link?.onTap;
  }
  if (spoiler != null) {
    onTap ??= toggleSpoiler;
  }

  TextStateHeader? header = state.getClosest();
  double? fontSize;
  if (header != null) {
    fontSize = Theme.of(context).textTheme.bodyText2!.fontSize!;
    fontSize = fontSize + (header.size * 2);
  }

  TextStateInlineCode? code = state.getClosest();

  Color? backgrounColor;
  if (spoiler != null) {
    if (isSpoilered) {
      backgrounColor =
          Theme.of(context).textTheme.bodyText2!.color!.withOpacity(1);
    } else {
      backgrounColor =
          Theme.of(context).textTheme.bodyText2!.color!.withOpacity(0.1);
    }
  } else if (code != null) {
    backgrounColor = Theme.of(context).cardColor;
  }

  return TextSpan(
    text: text,
    recognizer: onTap != null ? (TapGestureRecognizer()..onTap = onTap) : null,
    style: TextStyle(
      color: !isSpoilered && link != null ? Colors.blue[400] : null,
      fontWeight: state.hasState<TextStateBold>() ? FontWeight.bold : null,
      fontStyle: state.hasState<TextStateItalic>() ? FontStyle.italic : null,
      fontSize: fontSize,
      decoration: TextDecoration.combine([
        if (state.hasState<TextStateStrikeout>()) TextDecoration.lineThrough,
        if (state.hasState<TextStateUnderline>()) TextDecoration.underline,
        if (state.hasState<TextStateOverline>()) TextDecoration.overline,
      ]),
      backgroundColor: backgrounColor,
    ),
  );
}
