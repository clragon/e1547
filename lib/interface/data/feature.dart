import 'package:meta/meta.dart';

/// Provides utility for feature flagging.
///
/// Intended to be used on the base interface of a class that has feature flags.
/// The interface should call [throwUnsupported] for any method that is not
/// implemented, but is enabled by a feature flag.
///
/// Implementers should set the [features] field to the set of features that are
/// enabled for the implementation.
///
/// Users of the interface should check if a feature is enabled using [hasFeature]
/// before calling the method.
mixin FeatureFlagging<T extends Enum> {
  /// The set of features that are enabled for this implementation.
  Set<T> get features;

  /// Returns `true` if the given [feature] is enabled for this implementation.
  bool hasFeature(T feature) => features.contains(feature);

  /// Throws an [UnimplementedError] if the given [feature] is
  /// disabled or enabled but not implemented.
  ///
  /// Both are runtime errors and cannot be recovered from.
  @protected
  Never throwUnsupported(T feature) {
    if (hasFeature(feature)) {
      throw UnimplementedError(
        '$runtimeType has no implementation for $feature, '
        'despite it being enabled. Did you forget to implement it?',
      );
    }
    throw UnimplementedError('$runtimeType does not support feature $feature');
  }
}
