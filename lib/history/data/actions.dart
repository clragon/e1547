import 'package:e1547/app/data/link.dart';
import 'package:e1547/history/history.dart';

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

  String get name {
    if (title != null) {
      return title!;
    }

    Link? parsed = parseLink(link);
    LinkType? type = LinkType.values.asNameMap()[parsed?.type];
    if (parsed == null || type == null) {
      return link;
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

    if (parsed.id != null) {
      switch (type) {
        case LinkType.post:
          return 'Post #${parsed.id}';
        case LinkType.pool:
          return 'Pool #${parsed.id}';
        case LinkType.user:
          return 'User #${parsed.id}';
        case LinkType.wiki:
          return 'Wiki #${parsed.id}';
        case LinkType.topic:
          return 'Topic #${parsed.id}';
        case LinkType.reply:
          return 'Reply #${parsed.id}';
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
