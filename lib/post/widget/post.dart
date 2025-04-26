import 'package:cached_network_image/cached_network_image.dart';
import 'package:context_plus/context_plus.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:flutter/material.dart';

class PostPage extends StatelessWidget {
  const PostPage({
    super.key,
    required this.id,
  });

  final int id;

  @override
  Widget build(BuildContext context) {
    final client = ClientRef.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        forceMaterialTransparency: true,
      ),
      extendBodyBehindAppBar: true,
      body: QueryBuilder<Post, dynamic>(
        client.posts.getKey(id),
        () => client.posts.get(id: id),
        builder: (context, state) {
          if (state.isError) {
            return Center(child: Text('Error: ${state.error}'));
          }

          if (state.data case final post?) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                    child: Hero(
                      tag: 'post-$id',
                      child: post.sample != null
                          ? CachedNetworkImage(
                              imageUrl: post.sample!,
                              fit: BoxFit.cover,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
