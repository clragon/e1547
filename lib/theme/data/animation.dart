import 'package:flutter/material.dart';

@immutable
class AnimationTheme extends ThemeExtension<AnimationTheme> {
  const AnimationTheme({
    this.defaultDuration = const Duration(milliseconds: 200),
  });

  final Duration defaultDuration;

  @override
  AnimationTheme copyWith({Duration? defaultDuration}) {
    return AnimationTheme(
        defaultDuration: defaultDuration ?? this.defaultDuration);
  }

  @override
  AnimationTheme lerp(AnimationTheme? other, double t) {
    if (other is! AnimationTheme) {
      return this;
    }
    return AnimationTheme(
      defaultDuration: Duration(
        milliseconds: (defaultDuration.inMilliseconds * (1 - t) +
                other.defaultDuration.inMilliseconds * t)
            .round(),
      ),
    );
  }

  @override
  String toString() => 'AnimationTheme(defaultDuration: $defaultDuration)';
}

extension AnimationThemeExtension on ThemeData {
  AnimationTheme get animationTheme => extension<AnimationTheme>()!;
}
