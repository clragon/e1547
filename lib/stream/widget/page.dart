import 'package:e1547/shared/shared.dart';
import 'package:e1547/stream/data/controller.dart';
import 'package:flutter/widgets.dart';

class SubStreamPageController<T, P>
    extends SubValue<StreamPagingController<P, T>> {
  // ignore: use_key_in_widget_constructors
  SubStreamPageController({
    required P initialPageKey,
    required NextPageKeyCallback<P, T> getNextPageKey,
    required FetchPageCallback<P, T> fetchPage,
    super.keys,
    required Widget Function(
      BuildContext context,
      PagingState<P, T> state,
      NextPageCallback fetchNextPage,
    ) builder,
  }) : super(
          create: () => StreamPagingController<P, T>(
            getNextPageKey: getNextPageKey,
            fetchPage: fetchPage,
          ),
          builder: (context, controller) => PagingListener(
            controller: controller,
            builder: builder,
          ),
        );
}
