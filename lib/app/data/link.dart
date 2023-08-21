import 'dart:io';

import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/settings/settings.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/topic/topic.dart';
import 'package:e1547/user/user.dart';
import 'package:e1547/wiki/wiki.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as tabs;
import 'package:path_to_regexp/path_to_regexp.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as urls;

Future<void> launch(String url) async {
  Uri uri = Uri.parse(url);
  if ((Platform.isAndroid || Platform.isIOS) &&
      ['e621.net', 'e926.net'].contains(uri.host)) {
    await tabs.launch(url);
  } else {
    await urls.launchUrl(
      uri,
      mode: urls.LaunchMode.externalApplication,
    );
  }
}

const String queryDivider = r'[^\s/?&#]';
const String _queryRegex = r'(' + queryDivider + r'+)';
const String _showEnding = r':_(s|/show)';

enum LinkType {
  post,
  pool,
  user,
  wiki,
  topic,
  reply,
}

class Link {
  const Link({
    required this.type,
    this.id,
    this.search,
  });

  final LinkType type;
  final Object? id;
  final QueryMap? search;
}

class LinkParser {
  LinkParser({
    required this.path,
    required this.transformer,
  });

  final String path;
  final Link? Function(Map<String, String> args, QueryMap? query) transformer;

  Link? parse(String link) {
    Uri? uri = Uri.tryParse(link);
    if (uri == null) return null;

    List<String> names = [];
    Match? match = pathToRegExp(path, parameters: names, caseSensitive: false)
        .firstMatch(uri.path);

    if (match != null) {
      Map<String, String> arguments = extract(names, match);
      QueryMap? query = QueryMap.from(uri.queryParameters);
      if (query.isEmpty) query = null;
      return transformer(arguments, query);
    }

    return null;
  }
}

final List<LinkParser> allLinkParsers = [
  LinkParser(
    path: r'/post' '$_showEnding' r'/:id(\d+)',
    transformer: (args, query) => Link(
      type: LinkType.post,
      id: int.parse(args['id']!),
      search: query,
    ),
  ),
  LinkParser(
    path: r'/posts',
    transformer: (args, query) => Link(
      type: LinkType.post,
      search: query,
    ),
  ),
  LinkParser(
    path: r'/pool' '$_showEnding' r'/:id(\d+)',
    transformer: (args, query) => Link(
      type: LinkType.pool,
      search: query,
    ),
  ),
  LinkParser(
    path: r'/pools',
    transformer: (args, query) => Link(
      type: LinkType.pool,
      search: query,
    ),
  ),
  LinkParser(
    path: r'/user'
        '$_showEnding'
        r'/:name'
        '$_queryRegex',
    transformer: (args, query) => Link(
      type: LinkType.user,
      id: int.tryParse(args['name']!) ?? args['name']!,
      search: query,
    ),
  ),
  LinkParser(
    path: r'/wiki_pages'
        r'/:name'
        '$_queryRegex',
    transformer: (args, query) => Link(
      type: LinkType.wiki,
      id: int.tryParse(args['name']!) ?? args['name']!,
    ),
  ),
  LinkParser(
    path: r'/wiki_pages',
    transformer: (args, query) => Link(
      type: LinkType.wiki,
      search: query,
    ),
  ),
  LinkParser(
    path: r'/forum_topics/:id(\d+)',
    transformer: (args, query) => Link(
      type: LinkType.topic,
      id: int.parse(args['id']!),
      search: query,
    ),
  ),
  LinkParser(
    path: r'/forum_topics',
    transformer: (args, query) => Link(
      type: LinkType.topic,
      search: query,
    ),
  ),
  LinkParser(
    path: r'/forum_posts/:id(\d+)',
    transformer: (args, query) => Link(
      type: LinkType.reply,
      id: int.parse(args['id']!),
    ),
  ),
  LinkParser(
    path: r'/forum_posts',
    transformer: (args, query) => Link(
      type: LinkType.reply,
      search: query,
    ),
  ),
];

Link? parseLink(String link) {
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
    if (!context.read<Settings>().showBeta.value &&
        [LinkType.topic, LinkType.reply].contains(result.type)) {
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

    switch (result.type) {
      case LinkType.post:
        int? id = result.id as int?;
        if (id != null) {
          return navWrapper((context) => PostLoadingPage(id));
        }
        return navWrapper(
            (context) => PostsSearchPage(tags: result.search!['tags']));
      case LinkType.pool:
        int? id = result.id as int?;
        if (id != null) {
          return navWrapper((context) => PoolLoadingPage(id));
        }
        return navWrapper((context) => PoolsPage(search: result.search), true);
      case LinkType.user:
        Object? id = result.id;
        if (id != null) {
          return navWrapper((context) => UserLoadingPage(id.toString()));
        }
        break;
      case LinkType.wiki:
        Object? id = result.id;
        if (id != null) {
          return navWrapper((context) => WikiLoadingPage(id.toString()));
        }
        break;
      case LinkType.topic:
        int? id = result.id as int?;
        if (id != null) {
          return navWrapper((context) => TopicLoadingPage(id));
        }
        return navWrapper((context) => TopicsPage(search: result.search), true);
      case LinkType.reply:
        int? id = result.id as int?;
        if (id != null) {
          return navWrapper((context) => ReplyLoadingPage(id));
        }
        return navWrapper((context) => TopicsPage(search: result.search), true);
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
