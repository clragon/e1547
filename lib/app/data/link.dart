import 'dart:io';

import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/reply/reply.dart';
import 'package:e1547/settings/settings.dart';
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
    await tabs.launchUrl(
      uri,
      customTabsOptions: const tabs.CustomTabsOptions(
        browser: tabs.CustomTabsBrowserConfiguration(
          prefersDefaultBrowser: true,
        ),
      ),
    );
  } else {
    await urls.launchUrl(
      uri,
      mode: urls.LaunchMode.externalApplication,
    );
  }
}

const String queryDivider = r'[^\s/?&#]';
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
    this.query,
  });

  final LinkType type;
  final Object? id;
  final Map<String, String>? query;
}

@immutable
abstract class LinkParser {
  const LinkParser();

  Link? parse(String link);
}

class LeafLinkParser extends LinkParser {
  const LeafLinkParser({
    required this.path,
    required this.transformer,
  });

  final String path;
  final Link? Function(Map<String, String> args, Map<String, String>? query)
      transformer;

  @override
  Link? parse(String link) {
    Uri? uri = Uri.tryParse(link);
    if (uri == null) return null;

    List<String> names = [];
    Match? match = pathToRegExp(path, parameters: names, caseSensitive: false)
        .firstMatch(uri.path);

    if (match != null) {
      Map<String, String> arguments = extract(names, match);
      Map<String, String>? query = uri.queryParameters;
      if (query.isEmpty) query = null;
      return transformer(arguments, query);
    }

    return null;
  }
}

abstract class BranchLinkParser extends LinkParser {
  const BranchLinkParser();

  List<LinkParser> get parsers;

  @override
  Link? parse(String link) {
    for (LinkParser parser in parsers) {
      Link? result = parser.parse(link);
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}

class E621LinkParser extends BranchLinkParser {
  const E621LinkParser();

  @override
  List<LinkParser> get parsers => [
        LeafLinkParser(
          path: r'/post' '$_showEnding' r'/:id(\d+)',
          transformer: (args, query) => Link(
            type: LinkType.post,
            id: int.parse(args['id']!),
            query: query,
          ),
        ),
        LeafLinkParser(
          path: r'/posts',
          transformer: (args, query) => Link(
            type: LinkType.post,
            query: query,
          ),
        ),
        LeafLinkParser(
          path: r'/pool' '$_showEnding' r'/:id(\d+)',
          transformer: (args, query) => Link(
            type: LinkType.pool,
            id: int.parse(args['id']!),
            query: query,
          ),
        ),
        LeafLinkParser(
          path: r'/pools',
          transformer: (args, query) => Link(
            type: LinkType.pool,
            query: query,
          ),
        ),
        LeafLinkParser(
          path: r'/user'
              '$_showEnding'
              r'/:name',
          transformer: (args, query) => Link(
            type: LinkType.user,
            id: int.tryParse(args['name']!) ?? args['name']!,
            query: query,
          ),
        ),
        LeafLinkParser(
          path: r'/wiki_pages'
              r'/:name',
          transformer: (args, query) => Link(
            type: LinkType.wiki,
            id: int.tryParse(args['name']!) ?? args['name']!,
          ),
        ),
        LeafLinkParser(
          path: r'/wiki_pages',
          transformer: (args, query) => Link(
            type: LinkType.wiki,
            query: query,
          ),
        ),
        LeafLinkParser(
          path: r'/forum_topics/:id(\d+)',
          transformer: (args, query) => Link(
            type: LinkType.topic,
            id: int.parse(args['id']!),
            query: query,
          ),
        ),
        LeafLinkParser(
          path: r'/forum_topics',
          transformer: (args, query) => Link(
            type: LinkType.topic,
            query: query,
          ),
        ),
        LeafLinkParser(
          path: r'/forum_posts/:id(\d+)',
          transformer: (args, query) => Link(
            type: LinkType.reply,
            id: int.parse(args['id']!),
          ),
        ),
        LeafLinkParser(
          path: r'/forum_posts',
          transformer: (args, query) => Link(
            type: LinkType.reply,
            query: query,
          ),
        ),
      ];
}

extension LinkOnTapExtension on LinkParser {
  VoidCallback? parseOnTap(BuildContext context, String link) {
    final Link? result = this.parse(link);
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
          return navWrapper((context) => PostsSearchPage(query: result.query));
        case LinkType.pool:
          int? id = result.id as int?;
          if (id != null) {
            return navWrapper((context) => PoolLoadingPage(id));
          }
          return navWrapper((context) => PoolsPage(search: result.query), true);
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
          return navWrapper((context) => TopicsPage(query: result.query), true);
        case LinkType.reply:
          int? id = result.id as int?;
          if (id != null) {
            return navWrapper((context) => ReplyLoadingPage(id));
          }
          return navWrapper((context) => TopicsPage(query: result.query), true);
      }
    }
    return null;
  }

  bool open(BuildContext context, String link) {
    VoidCallback? callback = parseOnTap(context, link);
    if (callback != null) {
      callback();
      return true;
    }
    return false;
  }
}
