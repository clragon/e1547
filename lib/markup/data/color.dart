import 'package:flutter/material.dart';

Color? parseColor(String colorString) {
  if (RegExp(r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$').hasMatch(colorString)) {
    if (colorString.length == 7) {
      return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
    } else {
      String expandedHex =
          colorString.substring(1).split('').map((hex) => hex * 2).join();
      return Color(int.parse(expandedHex, radix: 16) + 0xFF000000);
    }
  }

  return HtmlColors.values.asNameMap()[colorString]?.value;
}

enum HtmlColors {
  mediumVioletRed(Color(0xFFC71585)),
  deepPink(Color(0xFFFF1493)),
  paleVioletRed(Color(0xFFDB7093)),
  hotPink(Color(0xFFFF69B4)),
  lightPink(Color(0xFFFFB6C1)),
  pink(Color(0xFFFFC0CB)),
  darkRed(Color(0xFF8B0000)),
  red(Color(0xFFFF0000)),
  firebrick(Color(0xFFB22222)),
  crimson(Color(0xFFDC143C)),
  indianRed(Color(0xFFCD5C5C)),
  lightCoral(Color(0xFFF08080)),
  salmon(Color(0xFFFA8072)),
  darkSalmon(Color(0xFFE9967A)),
  lightSalmon(Color(0xFFFFA07A)),
  orangeRed(Color(0xFFFF4500)),
  tomato(Color(0xFFFF6347)),
  darkOrange(Color(0xFFFF8C00)),
  coral(Color(0xFFFF7F50)),
  orange(Color(0xFFFFA500)),
  darkKhaki(Color(0xFFBDB76B)),
  gold(Color(0xFFFFD700)),
  khaki(Color(0xFFF0E68C)),
  peachPuff(Color(0xFFFFDAB9)),
  yellow(Color(0xFFFFFF00)),
  paleGoldenrod(Color(0xFFEEE8AA)),
  moccasin(Color(0xFFFFE4B5)),
  papayaWhip(Color(0xFFFFEFD5)),
  lightGoldenrodYellow(Color(0xFFFAFAD2)),
  lemonChiffon(Color(0xFFFFFACD)),
  lightYellow(Color(0xFFFFFFE0)),
  maroon(Color(0xFF800000)),
  brown(Color(0xFFA52A2A)),
  saddleBrown(Color(0xFF8B4513)),
  sienna(Color(0xFFA0522D)),
  chocolate(Color(0xFFD2691E)),
  darkGoldenrod(Color(0xFFB8860B)),
  peru(Color(0xFFCD853F)),
  rosyBrown(Color(0xFFBC8F8F)),
  goldenrod(Color(0xFFDAA520)),
  sandyBrown(Color(0xFFF4A460)),
  tan(Color(0xFFD2B48C)),
  burlywood(Color(0xFFDEB887)),
  wheat(Color(0xFFF5DEB3)),
  navajoWhite(Color(0xFFFFDEAD)),
  bisque(Color(0xFFFFE4C4)),
  blanchedAlmond(Color(0xFFFFEBCD)),
  cornsilk(Color(0xFFFFF8DC)),
  indigo(Color(0xFF4B0082)),
  purple(Color(0xFF800080)),
  darkMagenta(Color(0xFF8B008B)),
  darkViolet(Color(0xFF9400D3)),
  darkSlateBlue(Color(0xFF483D8B)),
  blueViolet(Color(0xFF8A2BE2)),
  darkOrchid(Color(0xFF9932CC)),
  fuchsia(Color(0xFFFF00FF)),
  magenta(Color(0xFFFF00FF)),
  slateBlue(Color(0xFF6A5ACD)),
  mediumSlateBlue(Color(0xFF7B68EE)),
  mediumOrchid(Color(0xFFBA55D3)),
  mediumPurple(Color(0xFF9370DB)),
  orchid(Color(0xFFDA70D6)),
  violet(Color(0xFFEE82EE)),
  plum(Color(0xFFDDA0DD)),
  thistle(Color(0xFFD8BFD8)),
  lavender(Color(0xFFE6E6FA)),
  midnightBlue(Color(0xFF191970)),
  navy(Color(0xFF000080)),
  darkBlue(Color(0xFF00008B)),
  mediumBlue(Color(0xFF0000CD)),
  blue(Color(0xFF0000FF)),
  royalBlue(Color(0xFF4169E1)),
  steelBlue(Color(0xFF4682B4)),
  dodgerBlue(Color(0xFF1E90FF)),
  deepSkyBlue(Color(0xFF00BFFF)),
  cornflowerBlue(Color(0xFF6495ED)),
  skyBlue(Color(0xFF87CEEB)),
  lightSkyBlue(Color(0xFF87CEFA)),
  lightSteelBlue(Color(0xFFB0C4DE)),
  lightBlue(Color(0xFFADD8E6)),
  powderBlue(Color(0xFFB0E0E6)),
  teal(Color(0xFF008080)),
  darkCyan(Color(0xFF008B8B)),
  lightSeaGreen(Color(0xFF20B2AA)),
  cadetBlue(Color(0xFF5F9EA0)),
  darkTurquoise(Color(0xFF00CED1)),
  mediumTurquoise(Color(0xFF48D1CC)),
  turquoise(Color(0xFF40E0D0)),
  aqua(Color(0xFF00FFFF)),
  cyan(Color(0xFF00FFFF)),
  aquamarine(Color(0xFF7FFFD4)),
  paleTurquoise(Color(0xFFAFEEEE)),
  lightCyan(Color(0xFFE0FFFF)),
  darkGreen(Color(0xFF006400)),
  green(Color(0xFF008000)),
  darkOliveGreen(Color(0xFF556B2F)),
  forestGreen(Color(0xFF228B22)),
  seaGreen(Color(0xFF2E8B57)),
  olive(Color(0xFF808000)),
  oliveDrab(Color(0xFF6B8E23)),
  mediumSeaGreen(Color(0xFF3CB371)),
  limeGreen(Color(0xFF32CD32)),
  lime(Color(0xFF00FF00)),
  springGreen(Color(0xFF00FF7F)),
  mediumSpringGreen(Color(0xFF00FA9A)),
  darkSeaGreen(Color(0xFF8FBC8F)),
  mediumAquamarine(Color(0xFF66CDAA)),
  yellowGreen(Color(0xFF9ACD32)),
  lawnGreen(Color(0xFF7CFC00)),
  chartreuse(Color(0xFF7FFF00)),
  lightGreen(Color(0xFF90EE90)),
  greenYellow(Color(0xFFADFF2F)),
  paleGreen(Color(0xFF98FB98)),
  snow(Color(0xFFFFFAFA)),
  honeydew(Color(0xFFF0FFF0)),
  mintCream(Color(0xFFF5FFFA)),
  azure(Color(0xFFF0FFFF)),
  aliceBlue(Color(0xFFF0F8FF)),
  ghostWhite(Color(0xFFF8F8FF)),
  whiteSmoke(Color(0xFFF5F5F5)),
  seashell(Color(0xFFFFF5EE)),
  beige(Color(0xFFF5F5DC)),
  oldLace(Color(0xFFFDF5E6)),
  floralWhite(Color(0xFFFFFAF0)),
  ivory(Color(0xFFFFFFF0)),
  antiqueWhite(Color(0xFFFAEBD7)),
  linen(Color(0xFFFAF0E6)),
  lavenderBlush(Color(0xFFFFF0F5)),
  mistyRose(Color(0xFFFFE4E1)),
  gainsboro(Color(0xFFDCDCDC)),
  lightGrey(Color(0xFFD3D3D3)),
  silver(Color(0xFFC0C0C0)),
  darkGray(Color(0xFFA9A9A9)),
  gray(Color(0xFF808080)),
  dimGray(Color(0xFF696969)),
  slateGray(Color(0xFF708090)),
  lightSlateGray(Color(0xFF778899)),
  darkSlateGray(Color(0xFF2F4F4F)),
  black(Color(0xFF000000));

  const HtmlColors(this.value);

  final Color value;
}