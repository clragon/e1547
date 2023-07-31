import 'package:flutter/foundation.dart';

@immutable
class MockItem {
  const MockItem(this.id);

  final Object id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MockItem && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'MockItem($id)';
}
