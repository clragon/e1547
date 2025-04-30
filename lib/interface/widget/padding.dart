import 'package:flutter/material.dart';

const double kContentPadding = 4;

const double defaultAppBarTopPadding = kContentPadding;
const double defaultAppBarHorizontalPadding = kContentPadding * 2;
const double defaultAppBarHeight = kToolbarHeight + defaultAppBarTopPadding;

const EdgeInsets defaultListPadding = EdgeInsets.symmetric(
  horizontal: kContentPadding,
  vertical: kContentPadding * 2,
);

const double defaultActionListBottomHeight = kBottomNavigationBarHeight + 24;

final EdgeInsets defaultActionListPadding =
    defaultListPadding.copyWith(bottom: defaultActionListBottomHeight);
