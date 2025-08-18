import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class FilterControllerProvider<T extends FilterController<R>, R>
    extends SubListenableProvider0<T> {
  // ignore: use_key_in_widget_constructors
  const FilterControllerProvider({
    required super.create,
    super.child,
    super.builder,
  });
}

typedef FilterableState<T, K> = InfiniteQueryStatus<List<T>, K>;

class QueryFilter<T, K> extends StatelessWidget {
  const QueryFilter({super.key, required this.state, required this.child});

  final FilterableState<T, K> state;
  final Widget Function(FilterableState<T, K>) child;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FilterController<T>>();
    return child(
      state.data != null
          ? state.copyWithData(
              InfiniteQueryData(
                pages: controller.filter(state.data!.pages),
                pageParams: state.data!.pageParams,
              ),
            )
          : state,
    );
  }
}
