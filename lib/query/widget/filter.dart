import 'package:e1547/query/query.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class FilterControllerProvider<C extends FilterController<T>, T>
    extends SubListenableProvider0<C> {
  // ignore: use_key_in_widget_constructors
  FilterControllerProvider({
    required super.create,
    super.child,
    TransitionBuilder? builder,
    super.keys,
  }) : super(
         builder: (context, child) =>
             // Also provide the generic version to allow [QueryFilter] to access the controller
             ListenableProvider<FilterController<T>>.value(
               value: context.read<C>(),
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
                    controller?.filterPages(state.data!.pages) ??
                    state.data!.pages,
                args: state.data!.args,
              ),
            )
          : state,
    );
  }
}
