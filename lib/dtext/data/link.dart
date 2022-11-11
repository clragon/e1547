import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/interface/interface.dart';
import 'package:flutter/material.dart';

import 'package:username_generator/username_generator.dart';

final DTextParser linkParser = DTextParser(
  regex: RegExp(
    linkWrap(
      r'(?<link>(http(s)?):\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*))',
      false,
    ),
  ),
  tranformer: (context, match, state) => parseDTextLink(
    context: context,
    name: match.namedGroup('name'),
    link: match.namedGroup('link')!,
    state: state,
  ),
);

final DTextParser localLinkParser = DTextParser(
  regex: RegExp(
    linkWrap(r'(?<link>[-a-zA-Z0-9()@:%_\+.~#?&//=]*)'),
  ),
  tranformer: (context, match, state) => parseDTextLink(
    context: context,
    name: match.namedGroup('name'),
    link: match.namedGroup('link')!,
    state: state,
    insite: true,
  ),
);

String stopsAtEndChar(String wrapped) => [
      wrapped,
      r'(?=([.,!\?:")\s])?)',
    ].join();

String startsWithName(String wrapped, [bool? needsName]) => [
      r'("(?<name>[^"]+?)":)',
      if (!(needsName ?? true)) r'?',
      wrapped,
    ].join();

String linkWrap(String wrapped, [bool? needsName]) =>
    startsWithName(stopsAtEndChar(wrapped), needsName);

String linkToDisplay(String link) {
  Uri url = Uri.parse(link.trim());
  List<String> allowed = ['v'];
  Map<String, dynamic> parameters = Map.of(url.queryParameters);
  parameters.removeWhere((key, value) => !allowed.contains(key));
  Uri newUrl = Uri(
    host: url.host,
    path: url.path,
    queryParameters: parameters.isNotEmpty ? parameters : null,
  );
  String display = newUrl.toString();
  List<String> removed = [r'^///?', r'^www.', r'/$'];
  for (String pattern in removed) {
    display = display.replaceFirst(RegExp(pattern), '');
  }
  return display;
}

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
      display = usernameGenerator.generate(int.parse(match.namedGroup('id')!));
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
        parsers: [tagParser],
      ),
    ],
  );
}
