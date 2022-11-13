import 'package:collection/collection.dart';
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

  List<TextStateSpoiler> spoilers = state.getAll();
  TextStateSpoiler? spoiler = state.getClosest();
  TextStateLink? link = state.getClosest();

  bool isSpoilered = spoilers.any((e) => spoilerController.isSpoilered(e.text));

  void toggleSpoiler() {
    TextStateSpoiler? spoiler =
        spoilers.firstWhereOrNull((e) => spoilerController.isSpoilered(e.text));
    if (spoiler != null) {
      spoilerController.unspoiler(spoiler.text);
    } else {
      spoilerController.respoiler(spoilers.last.text);
    }
  }

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

  Color? textColor;

  if (isSpoilered) {
    textColor = Colors.transparent;
  } else if (link != null) {
    textColor = Colors.blue[400];
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
      color: textColor,
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
