import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const MaterialColor primarySwatch = MaterialColor(0xFFFCB328, <int, Color>{
  50: Color(0xFFFFF6E5),
  100: Color(0xFFFEE8BF),
  200: Color(0xFFFED994),
  300: Color(0xFFFDCA69),
  400: Color(0xFFFCBE48),
  500: Color(0xFFFCB328),
  600: Color(0xFFFCAC24),
  700: Color(0xFFFBA31E),
  800: Color(0xFFFB9A18),
  900: Color(0xFFFA8B0F),
});

final Color accentColor = primarySwatch.shade400;

enum AppTheme {
  dark,
  amoled,
  light,
  blue;

  ThemeData get data {
    switch (this) {
      case AppTheme.light:
        return M2ThemeData.from(
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: primarySwatch,
            accentColor: accentColor,
            cardColor: Colors.white,
            backgroundColor: Colors.grey[50],
          ),
        ).copyWith(
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            foregroundColor: Colors.white,
          ),
        );
      case AppTheme.dark:
        return M2ThemeData.from(
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: primarySwatch,
            accentColor: accentColor,
            cardColor: Colors.grey[900],
            backgroundColor: const Color.fromARGB(255, 20, 20, 20),
            brightness: Brightness.dark,
          ),
        );
      case AppTheme.amoled:
        return M2ThemeData.from(
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: primarySwatch,
            accentColor: accentColor,
            cardColor: const Color.fromARGB(255, 20, 20, 20),
            backgroundColor: Colors.black,
            brightness: Brightness.dark,
          ),
        );
      case AppTheme.blue:
        return M2ThemeData.from(
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: primarySwatch,
            accentColor: accentColor,
            cardColor: const Color.fromARGB(255, 31, 60, 103),
            backgroundColor: const Color.fromARGB(255, 15, 33, 60),
            brightness: Brightness.dark,
          ),
        );
    }
  }
}

extension M2ThemeData on ThemeData {
  static ThemeData from({required ColorScheme colorScheme}) {
    final bool isDark = colorScheme.brightness == Brightness.dark;

    final Color primarySurfaceColor = isDark
        ? colorScheme.surface
        : colorScheme.primary;
    final Color onPrimarySurfaceColor = isDark
        ? colorScheme.onSurface
        : colorScheme.onPrimary;

    return prepareTheme(
      ThemeData(
        colorScheme: colorScheme,
        brightness: colorScheme.brightness,
        primaryColor: primarySurfaceColor,
        // ignore: deprecated_member_use
        canvasColor: colorScheme.background,
        // ignore: deprecated_member_use
        scaffoldBackgroundColor: colorScheme.background,
        cardColor: colorScheme.surface,
        dividerColor: colorScheme.onSurface.withAlpha(31),
        // ignore: deprecated_member_use
        dialogBackgroundColor: colorScheme.background,
        tabBarTheme: TabBarThemeData(indicatorColor: onPrimarySurfaceColor),
        applyElevationOverlayColor: isDark,
        useMaterial3: false,
      ),
    );
  }

  static ThemeData prepareTheme(ThemeData theme) => theme.copyWith(
    applyElevationOverlayColor: false,
    appBarTheme: theme.appBarTheme.copyWith(
      surfaceTintColor:
          theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: theme.brightness,
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
      backgroundColor: theme.canvasColor,
      foregroundColor: theme.iconTheme.color,
    ),
    dialogTheme: theme.dialogTheme.copyWith(
      backgroundColor: theme.canvasColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    cardTheme: theme.cardTheme.copyWith(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      color: theme.cardTheme.color,
    ),
    bannerTheme: theme.bannerTheme.copyWith(backgroundColor: theme.canvasColor),
    tooltipTheme: theme.tooltipTheme.copyWith(
      waitDuration: const Duration(milliseconds: 400),
    ),
    pageTransitionsTheme: SnapshotlessPageTransitionTheme(
      parent: theme.pageTransitionsTheme,
    ),
  );
}

class AndroidStretchScrollBehaviour extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    if (getPlatform(context) == TargetPlatform.android) {
      return StretchingOverscrollIndicator(
        axisDirection: details.direction,
        child: child,
      );
    }
    return super.buildOverscrollIndicator(context, child, details);
  }
}

class SnapshotlessPageTransitionTheme extends PageTransitionsTheme {
  const SnapshotlessPageTransitionTheme({this.parent});

  final PageTransitionsTheme? parent;

  @override
  Map<TargetPlatform, PageTransitionsBuilder> get builders =>
      _transformBuilders(parent);

  Map<TargetPlatform, PageTransitionsBuilder> _transformBuilders(
    PageTransitionsTheme? parent,
  ) {
    Map<TargetPlatform, PageTransitionsBuilder> builders = {};
    if (parent != null) {
      builders.addAll(
        Map.fromEntries(
          parent.builders.entries.map((e) {
            if (e.value is ZoomPageTransitionsBuilder) {
              return MapEntry(
                e.key,
                const ZoomPageTransitionsBuilder(allowSnapshotting: false),
              );
            } else {
              return e;
            }
          }),
        ),
      );
    }
    for (final platform in TargetPlatform.values) {
      if (builders[platform] == null) {
        builders[platform] = const ZoomPageTransitionsBuilder(
          allowSnapshotting: false,
        );
      }
    }
    return builders;
  }
}
