import 'package:e1547/client/client.dart';
import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:username_generator/username_generator.dart';

String stopsAtEndChar(String wrapped) => [
      wrapped,
      r'(?=([.,!:")\s]|(\? ))?)',
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

Map<RegExp, DTextParser> linkRegexes(BuildContext context) {
  return {
    RegExp(
      linkWrap(
        r'(?<link>(http(s)?):\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*))',
        false,
      ),
    ): (match, result, state) => parseLink(
          context: context,
          name: match.namedGroup('name'),
          link: match.namedGroup('link')!,
          state: state,
        ),
    RegExp(
      linkWrap(
        r'(?<link>[-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
      ),
    ): (match, result, state) => parseLink(
          context: context,
          name: match.namedGroup('name'),
          link: match.namedGroup('link')!,
          state: state,
          insite: true,
        ),
  };
}

InlineSpan parseLink({
  required BuildContext context,
  required String link,
  required String? name,
  required TextState state,
  bool insite = false,
}) {
  String? display = name ?? linkToDisplay(link);
  int? id = parseLinkId(link);
  LinkWord? word = parseLinkToWord(link);
  VoidCallback? onTap = () => launch(link);

  if (word != null && id != null) {
    onTap = getLinkWordTap(context, word, id);
  }

  if (insite) {
    onTap = () async => launch('https://${client.host}$link');

    UsernameGenerator? usernameGenerator = UsernameGeneratorData.of(context);

    // forum topics need generated names
    if (usernameGenerator != null && word == LinkWord.user) {
      display = usernameGenerator.generate(id!);
    }
  }

  return plainText(
    context: context,
    text: display,
    state: state.copyWith(link: true),
    onTap: onTap,
  );
}

int? parseLinkId(String link) {
  return int.tryParse(link.split('/').last.split('?').first);
}

LinkWord? parseLinkToWord(String link) {
  String siteMatch = r'((e621|e926)\.net)?';

  Map<String, LinkWord> links = {
    r'/post(s|/show)/\d+': LinkWord.post,
    r'/pool(s|/show)/\d+': LinkWord.pool,
    r'/user(s|/show)/\d+': LinkWord.user,
    if (settings.showBeta.value) ...{
      r'/forum_topics/\d+': LinkWord.topic,
      r'/forum_posts/\d+': LinkWord.forum,
    }
  };

  for (final entry in links.entries) {
    RegExpMatch? match =
        RegExp(siteMatch + entry.key, caseSensitive: false).firstMatch(link);
    if (match != null) {
      return entry.value;
    }
  }

  return null;
}

VoidCallback? getLinkAction(BuildContext context, String link) {
  int? id = parseLinkId(link);
  LinkWord? word = parseLinkToWord(link);

  if (word != null && id != null) {
    return getLinkWordTap(context, word, id);
  }

  return null;
}
