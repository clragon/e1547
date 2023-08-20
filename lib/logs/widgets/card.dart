import 'package:e1547/interface/interface.dart';
import 'package:e1547/logs/logs.dart';
import 'package:flutter/material.dart';

class LogStringCard extends StatelessWidget {
  const LogStringCard({
    super.key,
    required this.item,
    this.expanded = false,
  });

  final LogString item;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    String short = item.body.ellipse(100).split('\n').first;
    return LogRecordExpandable(
      key: ValueKey(item),
      color: item.level.color,
      title: Text(item.title),
      content: Text(short),
      fullContent: short != item.body ? LogStringBody(item: item) : null,
      expanded: expanded,
    );
  }
}

class LogStringBody extends StatelessWidget {
  const LogStringBody({super.key, required this.item});

  final LogString item;

  @override
  Widget build(BuildContext context) {
    String value = item.body;
    value = value.replaceAllMapped(RegExp(r'\r\n'), (_) => '\n');
    RegExp sectionRegex =
        RegExp(r'╔(?<title>[^═╗\n]*)(═*╗)?\n(?<content>(║.*?\n)*)(╚═*╝)');
    List<RegExpMatch> matches = sectionRegex.allMatches(value).toList();
    if (matches.isEmpty) {
      return Text(value.ellipse(500).split('\n').take(10).join('\n'));
    }
    int processed = 0;
    List<InlineSpan> spans = [];
    for (final match in matches) {
      spans.add(TextSpan(text: value.substring(processed, match.start)));
      processed = match.end;
      String title = match.namedGroup('title')!.trim();
      String content = match
          .namedGroup('content')!
          .trim()
          .split('\n')
          .map((e) => e.substring(1).trim())
          .join('\n');
      String short = content.ellipse(100);
      content = content.ellipse(1000).split('\n').take(10).join('\n');
      spans.add(
        WidgetSpan(
          child: LogRecordExpandable(
            key: ValueKey(Object.hash(item, content)),
            color: item.level.color,
            title: Text(title),
            content: Text(short),
            fullContent: short != content ? Text(content) : null,
          ),
        ),
      );
    }
    spans.add(TextSpan(text: value.substring(processed)));

    return Text.rich(TextSpan(children: spans));
  }
}
