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

const String _anyUrlRegex = ':_(.*)';
const String _queryRegex = r'([^&#]*)';

const String _showEnding = r':_(s|/show)';

String _singleQueryValue(String value) {
  return '$_anyUrlRegex'
      '$value'
      '$_queryRegex'
      '$_anyUrlRegex';
}

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
  final String urlPattern;
  final Link? Function(Map<String, Object> arguments) transformer;

  const LinkParser(this.urlPattern, this.transformer);

  Link? parse(String link) {
    List<String> names = [];
    Match? match = pathToRegExp(urlPattern, parameters: names).firstMatch(link);
    if (match != null) {
      Map<String, Object> arguments = extract(names, match);
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
    r'/posts',
    (arguments) => Link(type: LinkType.post.name),
  ),
  LinkParser(
    r'/posts?tags=:tags'
    '$_queryRegex',
    (arguments) => Link(
      type: LinkType.post.name,
      search: (arguments['tags'] as String).replaceAll('+', ' '),
    ),
  ),
  LinkParser(
    r'/post'
    '$_showEnding'
    r'/:id(\d+)',
    (arguments) => Link(
      type: LinkType.post.name,
      id: int.parse(arguments['id'] as String),
    ),
  ),
  LinkParser(
    r'/pools',
    (arguments) => Link(
      type: LinkType.pool.name,
    ),
  ),
  LinkParser(
    r'/pool'
    '$_showEnding'
    r'/:id(\d+)',
    (arguments) => Link(
      type: LinkType.pool.name,
      id: int.parse(arguments['id'] as String),
    ),
  ),
  LinkParser(
    r'/pools?' + _singleQueryValue(r'search[name_matches]=:name'),
    (arguments) => Link(
      type: LinkType.pool.name,
      search: arguments['name'] as String,
    ),
  ),
  LinkParser(
    r'/user'
    '$_showEnding'
    r'/:name'
    '$_queryRegex',
    (arguments) {
      int? id = int.tryParse(arguments['name'] as String);
      return Link(
        type: LinkType.user.name,
        id: id,
        name: id != null ? arguments['name'] as String : null,
      );
    },
  ),
  LinkParser(
    r'/wiki_pages'
    r'/:name'
    '$_queryRegex'
    '$_anyUrlRegex',
    (arguments) {
      int? id = int.tryParse(arguments['name'] as String);
      return Link(
        type: LinkType.wiki.name,
        id: id,
        name: id != null ? arguments['name'] as String : null,
      );
    },
  ),
  LinkParser(
    r'/forum_topics',
    (arguments) => Link(
      type: LinkType.topic.name,
    ),
  ),
  LinkParser(
    r'/forum_topics/:id(\d+)',
    (arguments) => Link(
      type: LinkType.topic.name,
      id: int.parse(arguments['id'] as String),
    ),
  ),
  LinkParser(
    r'/forum_topics/:id(\d+)?page=:index(\d+)',
    (arguments) => Link(
      type: LinkType.topic.name,
      id: int.parse(arguments['id'] as String),
      page: int.parse(arguments['index'] as String),
    ),
  ),
  LinkParser(
    r'/forum_topics?' + _singleQueryValue(r'search[title_matches]=:search'),
    (arguments) => Link(
      type: LinkType.topic.name,
      search: (arguments['search'] as String).replaceAll('+', ' '),
    ),
  ),
  LinkParser(
    r'/forum_posts/:id(\d+)',
    (arguments) => Link(
      type: LinkType.reply.name,
      id: int.parse(arguments['id'] as String),
    ),
  ),
  LinkParser(
    r'/forum_posts' + _singleQueryValue('search[topic_title_matches]=:search'),
    (arguments) => Link(
      type: LinkType.reply.name,
      search: (arguments['search'] as String).replaceAll('+', ' '),
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
        if (result.name != null) {
          return navWrapper((context) => UserLoadingPage(result.name!));
        }
        break;
      case LinkType.wiki:
        if (result.name != null) {
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
