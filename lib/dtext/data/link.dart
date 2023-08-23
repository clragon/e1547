import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

import 'package:username_generator/username_generator.dart';

class DTextLinkParser extends SpanDTextParser {
  @override
  RegExp get regex => RegExp(
        linkWrap(
          r'(?<link>(http(s)?):\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*))',
          false,
        ),
      );

  @override
  InlineSpan transformSpan(
      BuildContext context, RegExpMatch match, TextStateStack state) {
    return parseDTextLink(
      context: context,
      name: match.namedGroup('name'),
      link: match.namedGroup('link')!,
      state: state,
    );
  }

  String stopsAtEndChar(String wrapped) => [wrapped, r'(?<![.,;:!?")])'].join();

  String startsWithName(String wrapped, [bool? needsName]) => [
        r'("(?<name>[^"]+?)":)',
        if (!(needsName ?? true)) r'?',
        wrapped,
      ].join();

  String linkWrap(String wrapped, [bool? needsName]) =>
      startsWithName(stopsAtEndChar(wrapped), needsName);

  InlineSpan parseDTextLink({
    required BuildContext context,
    required String link,
    required String? name,
    required TextStateStack state,
    bool insite = false,
  }) {
    String? display = name ?? linkToDisplay(link);

    VoidCallback? onTap = () => launch(link);
    if (insite) {
      onTap = () async => launch('https://${context.read<Client>().host}$link');

      // forum topics need generated names
      UsernameGenerator? usernameGenerator = UsernameGeneratorData.of(context);
      RegExp userRegex = RegExp(r'/user(s|/show)/(?<id>\d+)');
      RegExpMatch? match = userRegex.firstMatch(link);
      if (usernameGenerator != null && match != null) {
        display =
            usernameGenerator.generate(int.parse(match.namedGroup('id')!));
      }
    }

    VoidCallback? callback = parseLinkOnTap(context, link);
    if (callback != null) {
      onTap = callback;
    }

    return TextSpan(
      children: [
        parseDText(
          context,
          display,
          state.push(TextStateLink(onTap)),
          parsers: [DTextTagParser()],
        ),
      ],
    );
  }
}

class DTextLocalLinkParser extends DTextLinkParser {
  @override
  RegExp get regex =>
      RegExp(linkWrap(r'(?<link>[-a-zA-Z0-9()@:%_\+.~#?&//=]*)'));

  @override
  InlineSpan transformSpan(
      BuildContext context, RegExpMatch match, TextStateStack state) {
    return parseDTextLink(
      context: context,
      name: match.namedGroup('name'),
      link: match.namedGroup('link')!,
      state: state,
      insite: true,
    );
  }
}
