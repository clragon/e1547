import 'package:e1547/domain/domain.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class PostLoadingPage extends StatelessWidget {
  const PostLoadingPage(this.id, {super.key});

  final int id;

  @override
  Widget build(BuildContext context) {
    final domain = context.watch<Domain>();
    return QueryBuilder(
      query: domain.posts.useGet(id: id),
      builder: (context, state) => LoadingPage(
        isLoading: state.isLoading,
        isError: state.isError,
        onError: const Text('Failed to load post'),
        onEmpty: const Text('Post not found'),
        builder: (context) => PostDetail(post: state.data!),
      ),
    );
  }
}
