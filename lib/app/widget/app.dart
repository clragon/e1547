import 'package:context_plus/context_plus.dart';
import 'package:dio/dio.dart';
import 'package:e1547/app/data/init.dart';
import 'package:e1547/app/widget/loading.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/settings/data/data.dart';
import 'package:e1547/theme/theme.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ContextPlus.root(
      child: AppLoadingScreen(
        init: initApp,
        builder: (context, initData) {
          final settings = SettingsRef.bindValue(context, initData.settings);

          final queryClient = QueryClientRef.bind(context, createQueryClient);
          ClientRef.bind(
            context,
            () => Client(
              dio: Dio(
                BaseOptions(
                  baseUrl: 'https://e621.net',
                  headers: {
                    'User-Agent': 'e1547/from-rubbble (binaryfloof)',
                  },
                ),
              ),
            ),
          );

          return QueryClientProvider(
            queryClient: queryClient,
            child: MaterialApp(
              theme: SettingsRef.watchOnly(
                context,
                (settings) => settings.value.theme.data,
              ),
              initialRoute: '/posts',
              routes: {
                '/': (_) => Scaffold(
                      appBar: AppBar(title: const Text('Home')),
                      body: Center(child: Builder(builder: (context) {
                        return Column(
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
                                  theme: settings.value.theme.data.brightness ==
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
                        );
                      })),
                    ),
                '/posts': (_) => const PostsPage(),
              },
            ),
          );
        },
      ),
    );
  }
}
