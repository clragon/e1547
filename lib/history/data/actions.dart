import 'package:e1547/app/data/link.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

extension Identification on History {
  bool isItem(LinkType type) {
    Link? parsed = parseLink(link);
    return type == LinkType.values.asNameMap()[parsed?.type] &&
        (parsed?.id != null || parsed?.name != null);
  }

  bool isSearch(LinkType type) {
    Link? parsed = parseLink(link);
    return type == LinkType.values.asNameMap()[parsed?.type] &&
        parsed?.search != null;
  }

  String getName(BuildContext context) {
    Link? parsed = parseLink(link);
    LinkType? type = LinkType.values.asNameMap()[parsed?.type];
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
          return tagToTitle(title!);
        default:
          break;
      }
      return title!;
    }

    if (parsed.name != null) {
      switch (type) {
        case LinkType.user:
          return 'User ${parsed.name}';
        case LinkType.wiki:
          return 'Wiki ${parsed.name}';
        default:
          break;
      }
    }

    int? id = parsed.id;
    if (id != null) {
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

    String? search = parsed.search;
    if (search != null && search.isNotEmpty) {
      switch (type) {
        case LinkType.post:
          String? username = context.read<Client>().credentials?.username;
          if (username != null && favRegex(username).hasMatch(search)) {
            return 'Favorites';
          }
          if (search == 'order:rank') {
            return 'Hot posts';
          }
          return 'Posts - ${tagToTitle(search)}';
        case LinkType.pool:
          return 'Pools - $search';
        case LinkType.user:
          return 'Users - $search';
        case LinkType.wiki:
          return 'Wikis - $search';
        case LinkType.topic:
          return 'Topics - $search';
        case LinkType.reply:
          return 'Replies - $search';
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
