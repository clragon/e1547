import 'package:e1547/dtext/dtext.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DText extends StatelessWidget {
  const DText(
    this.data, {
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.textAlign = TextAlign.start,
    this.softWrap = true,
  });

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
      return Text.rich(
        parseDText(context, result, const TextState()),
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
        softWrap: softWrap,
      );
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
              color: Theme.of(context).errorColor,
              size: 20,
            ),
          ),
          Text(
            'DText parsing has failed',
            style: TextStyle(color: Theme.of(context).errorColor),
          ),
        ],
      );
    }
  }
}
