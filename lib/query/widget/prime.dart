import 'package:e1547/query/query.dart';
import 'package:flutter/material.dart';

typedef QueryKeyGenerator<T> = List<Object> Function(T item);

class QueryCachePrimer<TItem, TError, TPageParam> extends StatefulWidget {
  const QueryCachePrimer({
    super.key,
    required this.result,
    required this.generateKey,
    required this.child,
  });

  final UseInfiniteQueryResult<List<TItem>, TError, TPageParam> result;
  final QueryKeyGenerator<TItem> generateKey;
  final Widget child;

  @override
  State<QueryCachePrimer<TItem, TError, TPageParam>> createState() =>
      _QueryCachePrimerState<TItem, TError, TPageParam>();
}

class _QueryCachePrimerState<TItem, TError, TPageParam>
    extends State<QueryCachePrimer<TItem, TError, TPageParam>> {
  Set<String> _previousKeys = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncCache();
    });
  }

  @override
  void didUpdateWidget(
      covariant QueryCachePrimer<TItem, TError, TPageParam> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncCache();
  }

  String _keyHash(List<Object?> key) => key.map((e) => e.toString()).join('/');

  void _syncCache() {
    final data = widget.result.data;
    if (data == null) {
      _previousKeys = {};
      return;
    }

    final queryClient = QueryClientProvider.of(context).queryClient;
    final updatedKeys = <String>{};

    for (final page in data.pages) {
      for (final item in page) {
        final key = widget.generateKey(item);
        final keyHash = _keyHash(key);

        updatedKeys.add(keyHash);

        if (!_previousKeys.contains(keyHash)) {
          queryClient.setQueryData<TItem>(key, (_) => item);
        }
      }
    }

    _previousKeys = updatedKeys;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
