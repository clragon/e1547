import 'dart:io';

import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:context_plus/context_plus.dart';
import 'package:dio/dio.dart';
import 'package:e1547/app/data/init.dart';
import 'package:e1547/app/widget/loading.dart';
import 'package:e1547/domain/domain.dart';
import 'package:e1547/identity/data/identity.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/settings/data/data.dart';
import 'package:e1547/theme/theme.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ContextPlus.root(
      child: AppLoadingScreen(
        init: initApp,
        builder: (context, initData) {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

          if (!CachedQuery.instance.isConfigSet) {
            CachedQuery.instance.configFlutter(
              config: const GlobalQueryConfigFlutter(
                refetchDuration: Duration(minutes: 5),
              ),
            );
          }

          final settings = SettingsRef.bindValue(context, initData.settings);

          DomainRef.bind(
            context,
            () => Domain(
              persona: (
                identity: const Identity(
                  id: 1,
                  host: 'https://e621.net',
                  username: 'test',
                  headers: {},
                ),
                traits: ValueNotifier(
                  const Traits(
                    id: 1,
                    userId: null,
                    denylist: [],
                    homeTags: '',
                    avatar: '',
                    perPage: null,
                  ),
                ),
              ),
              dio: Dio(
                BaseOptions(
                  baseUrl: 'https://e621.net',
                  headers: {
                    HttpHeaders.userAgentHeader:
                        'e1547/from-rubbble (binaryfloof)',
                    /*
                    HttpHeaders.authorizationHeader:
                        'Basic ${base64Encode(utf8.encode('a:b'))}',
                        */
                  },
                ),
              ),
            ),
          );

          return MaterialApp(
            theme: SettingsRef.watchOnly(
              context,
              (settings) => settings.value.theme.data,
            ),
            initialRoute: '/posts',
            routes: {
              '/': (context) => Scaffold(
                appBar: AppBar(title: const Text('Home')),
                body: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Home'),
                      IconButton(
                        icon: Icon(
                          settings.value.theme.data.brightness ==
                                  Brightness.light
                              ? Icons.brightness_7
                              : Icons.brightness_4,
                        ),
                        onPressed: () {
                          settings.value = settings.value.copyWith(
                            theme:
                                settings.value.theme.data.brightness ==
                                    Brightness.light
                                ? AppTheme.dark
                                : AppTheme.light,
                          );
                        },
                      ),
                      TextButton(
                        child: const Text('Go to posts'),
                        onPressed: () {
                          Navigator.pushNamed(context, '/posts');
                        },
                      ),
                    ],
                  ),
                ),
              ),
              '/posts': (_) => const PostsPage(),
            },
          );
        },
      ),
    );
  }
}
