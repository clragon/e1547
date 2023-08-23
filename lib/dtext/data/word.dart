import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/dtext/dtext.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  thumb;

  String toLink(int id) {
    switch (this) {
      case thumb:
      case post:
        return '/posts/$id';
      case pool:
        return '/pools/$id';
      case user:
        return '/users/$id';
      case forum:
        return '/forum_posts/$id';
      case topic:
        return '/forum_topics/$id';
      case comment:
        return '/comments/$id';
      case set:
        return '/post_sets/$id';
      case record:
        return '/user_feedbacks/$id';
      case blip:
        return '/blips/$id';
      case ticket:
        return '/tickets/$id';
      case takedown:
        return '/takedowns/$id';
      default:
        return '';
    }
  }
}

class DTextLinkWordParser extends SpanDTextParser {
  @override
  RegExp get regex => RegExp(
        r'((?<word>' +
            LinkWord.values.map((e) => RegExp.escape(e.name)).reduce(
                  (value, element) => ('$value|$element'),
                ) +
            r')' +
            r' #(?<id>\d+))',
        caseSensitive: false,
      );

  @override
  InlineSpan transformSpan(
      BuildContext context, RegExpMatch match, TextStateStack state) {
    return parseWord(
      context: context,
      word:
          LinkWord.values.asNameMap()[match.namedGroup('word')!.toLowerCase()]!,
      id: int.parse(match.namedGroup('id')!),
      result: match.between,
      state: state,
    );
  }

  InlineSpan parseWord({
    required BuildContext context,
    required LinkWord word,
    required int id,
    required String result,
    required TextStateStack state,
  }) =>
      plainText(
        context: context,
        text: result,
        state: state.push(
          TextStateLink(parseLinkOnTap(context, word.toLink(id)) ??
              () => launch(context.read<Client>().withHost(word.toLink(id)))),
        ),
      );
}
