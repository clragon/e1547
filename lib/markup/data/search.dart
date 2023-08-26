import 'package:e1547/markup/markup.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class DTextSearchParser extends SpanDTextParser {
  const DTextSearchParser();

  @override
  RegExp get regex => RegExp(r'{{(?<tags>.*?)(\|(?<name>.*?))?}}');

  @override
  InlineSpan transformSpan(
      BuildContext context, RegExpMatch match, TextStateStack state) {
    String? tags = match.namedGroup('tags');
    String name = match.namedGroup('name') ?? tags!;

    return plainText(
      context: context,
      text: name,
      state: state.push(
        TextStateLink(
          () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PostsSearchPage(tags: tags),
            ),
          ),
        ),
      ),
    );
  }
}
