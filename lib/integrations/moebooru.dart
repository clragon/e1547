import 'package:dio/dio.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/integrations/http/bridge.dart';
import 'package:e1547/integrations/moebooru/post.dart';
import 'package:e1547/integrations/moebooru/tags.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/foundation.dart';

class MoebooruClient extends Client with ClientAssembly {
  MoebooruClient({
    required this.identity,
    required this.traits,
    required this.storage,
  }) : dio = createDefaultDio(identity, cache: storage.httpCache) {
    final bridge =
        HttpBridgeService(dio: dio, identity: identity, traits: traits);
    final posts = MoebooruPostService(
      dio: dio,
    );
    final tags = MoebooruTagService(
      dio: dio,
    );

    enableServices(
      bridge: bridge,
      posts: posts,
      tags: tags,
    );
  }

  final Dio dio;

  final AppStorage storage;

  @override
  final Identity identity;

  @override
  final ValueNotifier<Traits> traits;

  @override
  void dispose() {
    super.dispose();
    dio.close();
  }
}
