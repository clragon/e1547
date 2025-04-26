import 'package:meta/meta.dart';

/// A class that wraps a [Type], with additional support for subclass checking.
///
/// Brought to you by https://github.com/abitofevrything <3
@immutable
class ReType<T> {
  /// Create a new [ReType];
  const ReType();

  /// The [Type] represented by this [ReType].
  Type get internalType => T;

  /// Returns whether [other] was declared as a type that is a subtype
  /// of the type this [ReType] represents.
  bool isSuperTypeOf<U>(ReType<U> other) => other is ReType<T>;

  /// Returns whether this [ReType] represents a type declared
  /// as a subtype of the type represented by [other].
  bool isSubTypeOf<U>(ReType<U> other) => other.isSuperTypeOf(this);

  /// Returns whether [object] is a subtype of the type represented by this [ReType].
  ///
  /// This is similar to the `is` operator.
  bool isSuperClassOfObject(Object? object) => object is T;

  @override
  String toString() => T.toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReType && other.internalType == internalType);

  @override
  int get hashCode => internalType.hashCode;
}
