import 'package:e1547/markup/markup.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DText extends StatelessWidget {
  const DText(
    this.data, {
    this.style,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.textAlign = TextAlign.start,
    this.softWrap = true,
  });

  final TextStyle? style;
  final int? maxLines;
  final TextOverflow overflow;
  final String data;
  final TextAlign textAlign;
  final bool softWrap;

  @override
  Widget build(BuildContext context) {
    String result = data.replaceAllMapped(RegExp(r'\r\n'), (_) => '\n');
    result = result.trim();

    try {
      Widget child = Expandables(
        child: SpoilerProvider(
          builder: (context, child) => Text.rich(
            parseDText(context, result, const TextStateStack()),
            maxLines: maxLines,
            overflow: overflow,
            textAlign: textAlign,
            softWrap: softWrap,
          ),
        ),
      );
      if (style != null) {
        return DefaultTextStyle(style: style!, child: child);
      } else {
        return child;
      }
    } on Exception {
      if (kDebugMode) {
        rethrow;
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              Icons.warning_amber_outlined,
              color: Theme.of(context).colorScheme.error,
              size: 20,
            ),
          ),
          Text(
            'DText parsing has failed',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
      );
    }
  }
}
