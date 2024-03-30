import 'package:dio/dio.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/identity/data/identity.dart';
import 'package:e1547/integrations/danbooru/comment.dart';
import 'package:e1547/integrations/danbooru/pool.dart';
import 'package:e1547/integrations/danbooru/post.dart';
import 'package:e1547/integrations/danbooru/tags.dart';
import 'package:e1547/integrations/danbooru/user.dart';
import 'package:e1547/integrations/danbooru/wiki.dart';
import 'package:e1547/integrations/http/bridge.dart';
import 'package:e1547/traits/data/traits.dart';
import 'package:flutter/foundation.dart';

class DanbooruClient extends Client with ClientAssembly {
  DanbooruClient({
    required this.identity,
    required this.traits,
    required this.storage,
  }) : dio = createDefaultDio(identity, cache: storage.httpCache) {
    final bridge = HttpBridgeService(
      dio: dio,
      identity: identity,
      traits: traits,
    );
    final posts = DanbooruPostService(dio: dio, identity: identity);
    final comments = DanbooruCommentService(dio: dio);
    final pools = DanbooruPoolService(dio: dio, postsClient: posts);
    final tags = DanbooruTagService(dio: dio);
    final users = DanbooruUserService(dio: dio);
    final wikis = DanbooruWikiService(dio: dio);

    enableServices(
      bridge: bridge,
      comments: comments,
      pools: pools,
      posts: posts,
      tags: tags,
      users: users,
      wikis: wikis,
    );
  }

  final Dio dio;

  final AppStorage storage;

  @override
  final Identity identity;

  @override
  final ValueNotifier<Traits> traits;
}
