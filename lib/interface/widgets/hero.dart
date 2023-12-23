import 'package:flutter/widgets.dart';

/// A widget that passes the [HeroController] from the nearest [HeroControllerScope] to its child.
/// This prevents the widget in [builder] from consuming the [HeroController].
class HeroControllerScopePassThrough extends StatelessWidget {
  const HeroControllerScopePassThrough({
    super.key,
    required this.child,
    required this.builder,
  });

  final Widget child;
  final Widget Function(BuildContext context, Widget child) builder;

  @override
  Widget build(BuildContext context) {
    HeroController? controller = HeroControllerScope.maybeOf(context);
    Widget child = this.child;
    if (controller != null) {
      child = HeroControllerScope(
        controller: controller,
        child: child,
      );
    }
    return HeroControllerScope.none(
      child: builder(context, child),
    );
  }
}
