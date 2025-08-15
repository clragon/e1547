import 'package:e1547/shared/shared.dart';
import 'package:e1547/stream/data/controller.dart';
import 'package:flutter_sub/flutter_sub.dart';

class SubStreamPageController<P, T>
    extends SubValue<StreamPagingController<P, T>> {
  // ignore: use_key_in_widget_constructors
  SubStreamPageController({
    required NextPageKeyCallback<P, T> getNextPageKey,
    required FetchPageCallback<P, T> fetchPage,
    super.keys,
    super.update,
    required super.builder,
  }) : super(
         create: () => StreamPagingController<P, T>(
           getNextPageKey: getNextPageKey,
           fetchPage: fetchPage,
         ),
       );
}
