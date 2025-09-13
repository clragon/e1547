import 'package:cached_query_flutter/cached_query_flutter.dart';
import 'package:e1547/domain/domain.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class PoolLoadingPage extends StatelessWidget {
  const PoolLoadingPage(this.id, {super.key});

  final int id;

  @override
  Widget build(BuildContext context) {
    final domain = context.watch<Domain>();
    return QueryBuilder(
      query: domain.pools.useGet(id: id),
      builder: (context, state) => LoadingPage(
        isLoading: state.isLoading,
        isError: state.isError,
        title: Text('Pool #$id'),
        onError: const Text('Failed to load pool'),
        onEmpty: const Text('Pool not found'),
        builder: (context) => PoolPage(pool: state.data!),
      ),
    );
  }
}
