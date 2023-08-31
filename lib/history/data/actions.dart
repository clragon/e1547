import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

extension Identification on History {
  bool isItem(LinkType type) {
    Link? parsed = const E621LinkParser().parse(link);
    return type == parsed?.type && parsed?.id != null;
  }

  bool isSearch(LinkType type) {
    Link? parsed = const E621LinkParser().parse(link);
    return type == parsed?.type && (parsed?.query?.isNotEmpty ?? false);
  }

  String getName(BuildContext context) {
    Link? parsed = const E621LinkParser().parse(link);
    LinkType? type = parsed?.type;
    if (parsed == null || type == null) {
      if (title != null) {
        return title!;
      }
      return link;
    }

    if (title != null) {
      switch (type) {
        case LinkType.pool:
        case LinkType.wiki:
          return tagToName(title!);
        default:
          break;
      }
      return title!;
    }

    if (parsed.id is String) {
      switch (type) {
        case LinkType.user:
          return '${parsed.id} - User';
        case LinkType.wiki:
          return '${parsed.id} - Wiki';
        default:
          break;
      }
    }

    if (parsed.id is int) {
      switch (type) {
        case LinkType.post:
          return 'Post #$id';
        case LinkType.pool:
          return 'Pool #$id';
        case LinkType.user:
          return 'User #$id';
        case LinkType.wiki:
          return 'Wiki #$id';
        case LinkType.topic:
          return 'Topic #$id';
        case LinkType.reply:
          return 'Reply #$id';
      }
    }

    QueryMap? search = parsed.query;
    if (search != null && search.isNotEmpty) {
      switch (type) {
        case LinkType.post:
          String? username = context.read<Client>().credentials?.username;
          if (username != null &&
              favRegex(username).hasMatch(search['tags'] ?? '')) {
            return 'Favorites';
          }
          if (search['tags'] == 'order:rank') {
            return 'Hot posts';
          }
          return 'Posts - ${tagToName(search['tags'] ?? '')}';
        case LinkType.pool:
          return 'Pools - ${search['search[name_matches]'] ?? ''}';
        case LinkType.user:
          return 'Users - ${search['search[name_matches]'] ?? ''}';
        case LinkType.wiki:
          return 'Wikis - ${search['search[title]'] ?? ''}';
        case LinkType.topic:
          return 'Topics - ${search['search[title_matches]'] ?? ''}';
        case LinkType.reply:
          return 'Replies - ${search['search[topic_title_matches]'] ?? ''}';
      }
    }

    switch (type) {
      case LinkType.post:
        return 'Posts';
      case LinkType.pool:
        return 'Pools';
      case LinkType.user:
        return 'Users';
      case LinkType.wiki:
        return 'Wikis';
      case LinkType.topic:
        return 'Topics';
      case LinkType.reply:
        return 'Replies';
    }
  }
}
