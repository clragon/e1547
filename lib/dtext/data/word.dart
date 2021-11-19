import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum LinkWord {
  post,
  forum,
  topic,
  comment,
  blip,
  pool,
  set,
  takedown,
  record,
  ticket,
  category,
  thumb,
}

Map<RegExp, DTextParser> linkWordRegexes(BuildContext context) {
  return Map.fromEntries(
    LinkWord.values.map(
      (word) => MapEntry(
        RegExp(RegExp.escape(describeEnum(word)) + r' #(?<id>\d+)',
            caseSensitive: false),
        (match, result, state) => parseWord(
          context: context,
          word: word,
          match: match,
          result: result,
          state: state,
        ),
      ),
    ),
  );
}

VoidCallback? getLinkWordTap(BuildContext context, LinkWord word, int id) {
  switch (word) {
    case LinkWord.thumb:
    // replace thumb with picture widget some day
    case LinkWord.post:
      return () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PostLoadingPage(id),
            ),
          );
    case LinkWord.pool:
      return () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PoolLoadingPage(id),
            ),
          );
    case LinkWord.forum:
      if (settings.showBeta.value) {
        return () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ReplyLoadingPage(id),
              ),
            );
      }
      break;
    case LinkWord.topic:
      if (settings.showBeta.value) {
        return () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TopicLoadingPage(id),
              ),
            );
      }
      break;
    default:
      return null;
  }
}

InlineSpan parseWord({
  required BuildContext context,
  required LinkWord word,
  required RegExpMatch match,
  required String result,
  required TextState state,
}) {
  int id = int.parse(match.namedGroup('id')!);

  VoidCallback? onTap = getLinkWordTap(context, word, id);

  return plainText(
    context: context,
    text: result,
    state: state.copyWith(link: true),
    onTap: onTap,
  );
}
