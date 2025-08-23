import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class FilterControllerProvider<T extends FilterController<R>, R>
    extends SubListenableProvider0<T> {
  // ignore: use_key_in_widget_constructors
  FilterControllerProvider({
    required super.create,
    super.child,
    TransitionBuilder? builder,
    super.keys,
  }) : super(
         builder: (context, child) =>
             // Also provide the generic version to allow [QueryFilter] to access the controller
             ListenableProvider<FilterController<R>>.value(
               value: context.read<T>(),
               builder: builder,
               child: child,
             ),
       );
}

typedef FilterableState<T, K> = InfiniteQueryStatus<List<T>, K>;

class QueryFilter<T, K> extends StatelessWidget {
  const QueryFilter({super.key, required this.state, required this.builder});

  final FilterableState<T, K> state;
  final Widget Function(BuildContext context, FilterableState<T, K> state)
  builder;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FilterController<T>?>();
    return builder(
      context,
      state.data != null
          ? state.copyWithData(
              InfiniteQueryData(
                pages:
                    controller?.filter(state.data!.pages) ?? state.data!.pages,
                pageParams: state.data!.pageParams,
              ),
            )
          : state,
    );
  }
}
