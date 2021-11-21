import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:username_generator/username_generator.dart';

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

Map<RegExp, DTextParser> linkRegexes(
  BuildContext context,
  UsernameGenerator? usernameGenerator,
) {
  return {
    RegExp(
      linkWrap(
        r'(?<link>(http(s)?):\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*))',
        false,
      ),
    ): (match, result, state) => parseLink(
          context: context,
          match: match,
          result: result,
          state: state,
          usernameGenerator: usernameGenerator,
        ),
    RegExp(
      linkWrap(
        r'(?<link>[-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
      ),
    ): (match, result, state) => parseLink(
          context: context,
          match: match,
          result: result,
          state: state,
          insite: true,
          usernameGenerator: usernameGenerator,
        ),
  };
}

InlineSpan parseLink({
  required BuildContext context,
  required RegExpMatch match,
  required String result,
  required TextState state,
  UsernameGenerator? usernameGenerator,
  bool insite = false,
}) {
  String? display = match.namedGroup('name');
  String search = match.namedGroup('link')!;
  String siteMatch = r'((e621|e926)\.net)?';
  VoidCallback onTap = () => launch(search);
  int? id = int.tryParse(search.split('/').last.split('?').first);

  if (display == null) {
    display = match.namedGroup('link');
    display = linkToDisplay(display!);
  }

  if (insite) {
    onTap = () async => launch('https://${settings.host.value}$search');

    // forum topics need generated names
    if (usernameGenerator != null) {
      RegExp userReg = RegExp(r'/user(s|/show)/\d+');
      if (userReg.hasMatch(search)) {
        display = usernameGenerator.generate(id!);
      }
    }
  }

  if (id != null) {
    Map<RegExp, Function? Function(RegExpMatch match)> links = {
      RegExp(siteMatch + r'/post(s|/show)/\d+'): (match) =>
          getLinkWordTap(context, LinkWord.post, id),
      RegExp(siteMatch + r'/pool(s|/show)/\d+'): (match) =>
          getLinkWordTap(context, LinkWord.pool, id),
      RegExp(siteMatch + r'/user(s|/show)/\d+'): (match) =>
          getLinkWordTap(context, LinkWord.user, id),
      if (settings.showBeta.value) ...{
        RegExp(siteMatch + r'/forum_topics/\d+'): (match) =>
            getLinkWordTap(context, LinkWord.topic, id),
        RegExp(siteMatch + r'/forum_posts/\d+'): (match) =>
            getLinkWordTap(context, LinkWord.forum, id),
      }
    };

    for (MapEntry<RegExp, Function(RegExpMatch match)> entry in links.entries) {
      RegExpMatch? match = entry.key.firstMatch(result);
      if (match != null) {
        onTap = entry.value(match);
        break;
      }
    }
  }

  return plainText(
    context: context,
    text: display,
    state: state.copyWith(link: true),
    onTap: onTap,
  );
}
