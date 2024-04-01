import 'package:dio/dio.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/integrations/gelbooru/post.dart';
import 'package:e1547/integrations/http.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/foundation.dart';

/// for Gelbooru Beta 0.2.0
class GelbooruClient extends Client with ClientAssembly {
  GelbooruClient({
    required this.identity,
    required this.traits,
    required this.storage,
  }) : dio = createDefaultDio(identity, cache: storage.httpCache) {
    final bridge =
        HttpBridgeService(dio: dio, identity: identity, traits: traits);
    final posts = GelbooruPostService(
      dio: dio,
      identity: identity,
    );

    enableServices(
      bridge: bridge,
      posts: posts,
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
