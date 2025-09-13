import 'package:e1547/domain/domain.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class FavPage extends StatelessWidget {
  const FavPage({super.key});

  @override
  Widget build(BuildContext context) {
    final domain = context.watch<Domain>();
    return RouterDrawerEntry<FavPage>(
      child: domain.identity.username == null
          ? const AdaptiveScaffold(
              appBar: DefaultAppBar(title: Text('Favorites')),
              body: Center(
                child: Text('Favorites are unavailable for anonymous users'),
              ),
            )
          : PostsPage(
              query: (PostParams()..addTag('fav:${domain.identity.username}'))
                  .value,
            ),
    );
  }
}
