double notZero(double value) => value < 1 ? 1 : value;

int roundedNotZero(double value) => value.round() == 0 ? 1 : value.round();
