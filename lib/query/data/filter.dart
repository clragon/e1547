import 'package:flutter/foundation.dart';

abstract class FilterController<T> extends ChangeNotifier {
  FilterController();

  List<T> filter(List<T> items);
}

extension FilterControllerPages<T> on FilterController<T> {
  List<List<T>> filterPages(List<List<T>> pages) => pages.map(filter).toList();
}
