import 'dart:io';

import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/topic/topic.dart';
import 'package:e1547/user/user.dart';
import 'package:e1547/wiki/wiki.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as tabs;
import 'package:path_to_regexp/path_to_regexp.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as urls;

Future<void> launch(String uri) async {
  if ((Platform.isAndroid || Platform.isIOS) &&
      RegExp(r'http(s)?://(e621|e926)\.net/*').hasMatch(uri)) {
    tabs.launch(uri);
  } else {
    urls.launchUrl(Uri.parse(uri), mode: urls.LaunchMode.externalApplication);
  }
}

const String _queryRegex = r'([^/&#]+)';
const String _showEnding = r':_(s|/show)';

class Link {
  final String type;
  final int? id;
  final String? name;
  final String? search;
  final int? page;

  const Link({
    required this.type,
    this.id,
    this.name,
    this.search,
    this.page,
  });
}

class LinkParser {
  final String path;
  final List<String>? parameters;
  final Link? Function(Map<String, String> arguments) transformer;

  LinkParser({
    required this.path,
    this.parameters,
    required this.transformer,
  });

  final RegExp _parameterPattern = RegExp(
    r'^(?<name>[^ ()?]+)(?<pattern>\(\S+\))?(?<optional>\?)?',
    caseSensitive: false,
  );

  Link? parse(String link) {
    Uri? url = Uri.tryParse(link);
    if (url == null) {
      return null;
    }

    List<String> names = [];
    Match? match = pathToRegExp(path, parameters: names, caseSensitive: false)
        .firstMatch(url.path);
    if (match != null) {
      Map<String, String> arguments = extract(names, match);

      if (parameters != null) {
        for (final argument in parameters!) {
          RegExpMatch match = _parameterPattern.firstMatch(argument)!;
          String name = match.namedGroup('name')!;
          String? pattern = match.namedGroup('pattern');
          bool optional = match.namedGroup('optional') != null;

          String? value = url.queryParameters[name];
          if (value == null) {
            if (optional) continue;
            return null;
          }
          if (pattern != null && !RegExp(pattern).hasMatch(value)) {
            if (optional) continue;
            return null;
          }
          arguments[name] = value;
        }
      }

      return transformer(arguments);
    }

    return null;
  }
}

enum LinkType {
  post,
  pool,
  user,
  wiki,
  topic,
  reply,
}

final List<LinkParser> allLinkParsers = [
  LinkParser(
    path: r'/post' '$_showEnding' r'/:id(\d+)',
    parameters: [r'q?'],
    transformer: (arguments) => Link(
      type: LinkType.post.name,
      id: int.parse(arguments['id']!),
      search: arguments['q'],
    ),
  ),
  LinkParser(
    path: r'/posts',
    parameters: [r'tags?'],
    transformer: (arguments) => Link(
      type: LinkType.post.name,
      search: arguments['tags'],
    ),
  ),
  LinkParser(
    path: r'/pool' '$_showEnding' r'/:id(\d+)',
    transformer: (arguments) => Link(
      type: LinkType.pool.name,
      id: int.parse(arguments['id']!),
    ),
  ),
  LinkParser(
    path: r'/pools',
    parameters: [r'search[name_matches]?'],
    transformer: (arguments) => Link(
      type: LinkType.pool.name,
      search: arguments['search[name_matches]']!,
    ),
  ),
  LinkParser(
    path: r'/user'
        '$_showEnding'
        r'/:name'
        '$_queryRegex',
    transformer: (arguments) {
      int? id = int.tryParse(arguments['name']!);
      return Link(
        type: LinkType.user.name,
        id: id,
        name: id == null ? arguments['name']! : null,
      );
    },
  ),
  LinkParser(
    path: r'/wiki_pages'
        r'/:name'
        '$_queryRegex',
    transformer: (arguments) {
      int? id = int.tryParse(arguments['name']!);
      return Link(
        type: LinkType.wiki.name,
        id: id,
        name: id == null ? arguments['name']! : null,
      );
    },
  ),
  LinkParser(
    path: r'/forum_topics/:id(\d+)',
    parameters: [r'page(\d+)?'],
    transformer: (arguments) => Link(
      type: LinkType.topic.name,
      id: int.parse(arguments['id']!),
      page: arguments['page'] != null ? int.parse(arguments['page']!) : null,
    ),
  ),
  LinkParser(
    path: r'/forum_topics',
    parameters: [r'search[title_matches]'],
    transformer: (arguments) => Link(
      type: LinkType.topic.name,
      search: arguments[r'search[title_matches]']!,
    ),
  ),
  LinkParser(
    path: r'/forum_posts/:id(\d+)',
    transformer: (arguments) => Link(
      type: LinkType.reply.name,
      id: int.parse(arguments['id']!),
    ),
  ),
  LinkParser(
    path: r'/forum_posts',
    parameters: [r'search[topic_title_matches]'],
    transformer: (arguments) => Link(
      type: LinkType.reply.name,
      search: arguments[r'search[topic_title_matches]'],
    ),
  ),
];

Link? parseLink(String link) {
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

  for (LinkParser parser in allLinkParsers) {
    Link? result = parser.parse(link);
    if (result != null) {
      return result;
    }
  }
  return null;
}

VoidCallback? parseLinkOnTap(BuildContext context, String link) {
  final Link? result = parseLink(link);
  if (result != null) {
    LinkType? type = LinkType.values.asNameMap()[result.type];
    if (!context.watch<Settings>().showBeta.value &&
        [LinkType.topic, LinkType.reply].contains(type)) {
      return null;
    }

    VoidCallback navWrapper(WidgetBuilder builder, [bool root = false]) {
      return () {
        if (root) {
          Navigator.of(context).popUntil((route) => false);
        }
        Navigator.of(context).push(
          MaterialPageRoute(builder: builder),
        );
      };
    }

    switch (type) {
      case LinkType.post:
        if (result.id != null) {
          return navWrapper((context) => PostLoadingPage(result.id!));
        }
        return navWrapper((context) => SearchPage(tags: result.search));
      case LinkType.pool:
        if (result.id != null) {
          return navWrapper((context) => PoolLoadingPage(result.id!));
        }
        return navWrapper((context) => PoolsPage(search: result.search), true);
      case LinkType.user:
        String? name = result.name ?? result.id?.toString();
        if (name != null) {
          return navWrapper((context) => UserLoadingPage(result.name!));
        }
        break;
      case LinkType.wiki:
        String? name = result.name ?? result.id?.toString();
        if (name != null) {
          return navWrapper((context) => WikiLoadingPage(result.name!));
        }
        break;
      case LinkType.topic:
        if (result.id != null) {
          return navWrapper((context) => TopicLoadingPage(result.id!));
        }
        return navWrapper((context) => TopicsPage(search: result.search), true);
      case LinkType.reply:
        if (result.id != null) {
          return navWrapper((context) => ReplyLoadingPage(result.id!));
        }
        return navWrapper((context) => TopicsPage(search: result.search), true);
      case null:
        return null;
    }
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
