import 'package:dio/dio.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/identity/data/identity.dart';
import 'package:e1547/integrations/danbooru/post.dart';
import 'package:e1547/integrations/danbooru/traits.dart';
import 'package:e1547/traits/data/traits.dart';
import 'package:flutter/foundation.dart';

class DanbooruClient extends Client with ClientAssembly {
  DanbooruClient({
    required this.identity,
    required this.traitsState,
    required this.storage,
  }) : dio = createDefaultDio(identity, cache: storage.httpCache) {
    final posts = DanbooruPostsClient(dio: dio);
    final traits = DanbooruTraitsClient(traits: traitsState);

    enableClients(
      posts: posts,
      traits: traits,
    );
  }

  final Dio dio;

  final AppStorage storage;

  @override
  final Identity identity;

  @override
  final ValueNotifier<Traits> traitsState;
}
