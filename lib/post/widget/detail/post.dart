import 'package:cached_network_image/cached_network_image.dart';
import 'package:context_plus/context_plus.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/stream/stream.dart';
import 'package:flutter/material.dart';

class PostDetailPage extends StatelessWidget {
  const PostDetailPage({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    final client = ClientRef.of(context);
    return SubStreamFuture(
      create: () => client.posts.get(id: id),
      builder: (context, state) {
        if (state.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Post'),
              forceMaterialTransparency: true,
            ),
            extendBodyBehindAppBar: true,
            body: Center(child: Text('Error: ${state.error}')),
          );
        }

        if (state.data case final post?) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Post'),
              forceMaterialTransparency: true,
            ),
            extendBodyBehindAppBar: true,
            body: SingleChildScrollView(
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
            ),
            floatingActionButton: FloatingActionButton(
              child: post.isFavorited
                  ? const Icon(Icons.favorite, color: Colors.red)
                  : const Icon(Icons.favorite),
              onPressed: () {
                if (post.isFavorited) {
                  client.posts.removeFavorite(id);
                } else {
                  client.posts.addFavorite(id);
                }
              },
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Post'),
            forceMaterialTransparency: true,
          ),
          extendBodyBehindAppBar: true,
          body: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
