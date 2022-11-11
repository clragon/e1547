import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/wiki/wiki.dart';
import 'package:flutter/material.dart';

final DTextParser anchorParser = DTextParser(
  regex: RegExp(r'\[\[(?<anchor>#)?(?<tags>.*?)(\|(?<name>.*?))?\]\]'),
  tranformer: (context, match, state) {
    bool anchor = match.namedGroup('anchor') != null;
    String tags = match.namedGroup('tags')!;
    String name = match.namedGroup('name') ?? tags;

    tags = tags.replaceAll(' ', '_');

    VoidCallback? onTap;

    if (!anchor) {
      if (!tags.contains(' ') && wikiMetaTags.any((e) => tags.startsWith(e))) {
        onTap = () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => WikiLoadingPage(tags),
              ),
            );
      } else {
        onTap = () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SearchPage(tags: tags),
              ),
            );
      }
    }

    return plainText(
      context: context,
      text: name,
      state: state.push(TextStateLink(onTap)),
    );
  },
);
