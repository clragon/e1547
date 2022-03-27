import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/topic/topic.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';

enum LinkWord {
  post,
  forum,
  topic,
  comment,
  user,
  blip,
  pool,
  set,
  takedown,
  record,
  ticket,
  category,
  thumb,
}

List<DTextParser> linkWordParsers() => LinkWord.values
    .map(
      (word) => DTextParser(
        regex: RegExp(RegExp.escape(word.name) + r' #(?<id>\d+)',
            caseSensitive: false),
        tranformer: (context, match, state) => parseWord(
          context: context,
          word: word,
          id: int.parse(match.namedGroup('id')!),
          result: match.between,
          state: state,
        ),
      ),
    )
    .toList();

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
    case LinkWord.user:
      return () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => UserLoadingPage(id.toString()),
            ),
          );
    case LinkWord.forum:
      return settings.showBeta.value
          ? () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ReplyLoadingPage(id),
                ),
              )
          : null;
    case LinkWord.topic:
      return settings.showBeta.value
          ? () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TopicLoadingPage(id),
                ),
              )
          : null;
    default:
      return null;
  }
}

InlineSpan parseWord({
  required BuildContext context,
  required LinkWord word,
  required int id,
  required String result,
  required TextState state,
}) {
  VoidCallback? onTap = getLinkWordTap(context, word, id);

  return plainText(
    context: context,
    text: result,
    state: state.copyWith(
      link: true,
      onTap: onTap,
    ),
  );
}
