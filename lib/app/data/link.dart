import 'dart:io';

import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/topic/topic.dart';
import 'package:e1547/user/user.dart';
import 'package:flutter/material.dart';
import 'package:path_to_regexp/path_to_regexp.dart';
import 'package:url_launcher/url_launcher.dart' as urls;
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as tabs;

Future<void> launch(String uri) async {
  if ((Platform.isAndroid || Platform.isIOS) &&
      RegExp(r'http(s)?://(e621|e926)\.net/*').hasMatch(uri)) {
    tabs.launch(uri);
  } else {
    urls.launchUrl(Uri.parse(uri), mode: urls.LaunchMode.externalApplication);
  }
}

const String _anyUrlRegex = ':_(.*)';
const String _queryRegex = r'([^&#]*)';

const String _showEnding = r':_(s|/show)';

String _singleQueryValue(String value) {
  return '$_anyUrlRegex'
      '$value'
      '$_queryRegex'
      '$_anyUrlRegex';
}

class LinkParser {
  final String urlPattern;
  final LinkParserResult? Function(
      BuildContext context, Map<String, Object> arguments) transformer;

  LinkParser(this.urlPattern, this.transformer);
}

class LinkParserResult {
  final WidgetBuilder builder;
  final bool root;

  const LinkParserResult(this.builder, {this.root = false});
}

List<LinkParser> allLinkParsers() => [
      LinkParser(
        r'/posts',
        (context, arguments) => LinkParserResult(
          (context) => const SearchPage(),
        ),
      ),
      LinkParser(
        r'/posts?tags=:tags'
        '$_queryRegex',
        (context, arguments) => LinkParserResult(
          (context) => SearchPage(
            tags: (arguments['tags'] as String).replaceAll('+', ' '),
          ),
        ),
      ),
      LinkParser(
        r'/post'
        '$_showEnding'
        r'/:id(\d+)',
        (context, arguments) => LinkParserResult(
          (context) => PostLoadingPage(
            int.parse(arguments['id'] as String),
          ),
        ),
      ),
      LinkParser(
        r'/pools',
        (context, arguments) => LinkParserResult(
          (context) => const PoolsPage(),
          root: true,
        ),
      ),
      LinkParser(
        r'/pool'
        '$_showEnding'
        r'/:id(\d+)',
        (context, arguments) => LinkParserResult(
          (context) => PoolLoadingPage(
            int.parse(arguments['id'] as String),
          ),
        ),
      ),
      LinkParser(
        r'/pools?' + _singleQueryValue(r'search[name_matches]=:name'),
        (context, arguments) => LinkParserResult(
          (context) => PoolsPage(
            search: arguments['name'] as String,
          ),
          root: true,
        ),
      ),
      LinkParser(
        r'/user'
        '$_showEnding'
        r'/:name'
        '$_queryRegex',
        (context, arguments) => LinkParserResult(
          (context) => UserLoadingPage(
            arguments['name'] as String,
          ),
        ),
      ),
      // TODO: add user search page
      if (settings.showBeta.value) ...forumLinkParsers,
    ];

final List<LinkParser> forumLinkParsers = [
  LinkParser(
    r'/forum_topics',
    (context, arguments) => LinkParserResult(
      (context) => const TopicsPage(),
      root: true,
    ),
  ),
  LinkParser(
    r'/forum_topics/:id(\d+)',
    (context, arguments) => LinkParserResult(
      (context) => TopicLoadingPage(
        int.parse(arguments['id'] as String),
      ),
    ),
  ),
  LinkParser(
    r'/forum_topics/:id(\d+)?page=:index(\d+)',
    (context, arguments) => LinkParserResult(
      (context) => ReplyLoadingPage(
        int.parse(arguments['id'] as String),
      ),
    ),
  ),
  LinkParser(
    r'/forum_topics?' + _singleQueryValue(r'search[title_matches]=:search'),
    (context, arguments) => LinkParserResult(
      (context) => TopicsPage(
        search: (arguments['search'] as String).replaceAll('+', ' '),
      ),
      root: true,
    ),
  ),
  LinkParser(
    r'/forum_posts/:id(\d+)',
    (context, arguments) => LinkParserResult(
      (context) => ReplyLoadingPage(
        int.parse(arguments['id'] as String),
      ),
    ),
  ),
  LinkParser(
    r'/forum_posts' + _singleQueryValue('search[topic_title_matches]=:search'),
    (context, arguments) => LinkParserResult(
      (context) => TopicsPage(
        search: (arguments['search'] as String).replaceAll('+', ' '),
      ),
      root: true,
    ),
  ),
];

LinkParserResult? parseLink(BuildContext context, String link) {
  Uri? url = Uri.tryParse(link);
  if (url != null) {
    if (['e621.net', 'e926.net'].any((e) => e == url!.host)) {
      url = url.replace(scheme: '', host: '');
      link = url.toString();
    }
  }
  if (link.startsWith('///')) {
    link = link.substring(2);
  }
  if (link.endsWith('/')) {
    link = link.substring(0, link.length - 1);
  }
  link = Uri.decodeFull(link);

  for (LinkParser parser in allLinkParsers()) {
    List<String> names = [];
    Match? match =
        pathToRegExp(parser.urlPattern, parameters: names).firstMatch(link);
    if (match != null) {
      Map<String, Object> arguments = extract(names, match);
      LinkParserResult? result = parser.transformer(context, arguments);
      if (result != null) {
        return result;
      }
    }
  }
  return null;
}

VoidCallback? parseLinkOnTap(BuildContext context, String link) {
  LinkParserResult? result = parseLink(context, link);
  if (result != null) {
    return () {
      if (result.root) {
        Navigator.of(context).popUntil((route) => false);
      }
      Navigator.of(context).push(
        MaterialPageRoute(builder: result.builder),
      );
    };
  }
  return null;
}

bool executeLink(BuildContext context, String link) {
  VoidCallback? callback = parseLinkOnTap(context, link);
  if (callback != null) {
    callback();
    return true;
  }
  return false;
}
