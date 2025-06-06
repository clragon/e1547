import 'package:collection/collection.dart';
import 'package:e1547/tag/tag.dart';
import 'package:petitparser/petitparser.dart';

class TagMapParserDefinition extends GrammarDefinition<List<TagNode>> {
  @override
  Parser<List<TagNode>> start() =>
      ref0(node).starSeparated(whitespace().plus()).map((e) => e.elements);

  Parser<TagNode> node() =>
      [ref0(group), ref0(tagWithValue), ref0(tagRaw)].toChoiceParser();

  Parser<TagGroup> group() => (
    ref0(prefix).optional(),
    char('('),
    whitespace(),
    (
      (char(')'), whitespace()).toSequenceParser().not(),
      ref0(node),
      whitespace(),
    ).toSequenceParser().map((rec) => rec.$2).star(),
    char(')'),
  ).toSequenceParser().map((rec) => TagGroup(rec.$1 ?? '', rec.$4));

  Parser<TagValue> tagWithValue() => (
    ref0(key),
    char(':'),
    ref0(value),
  ).toSequenceParser().map((rec) => TagValue(rec.$1, rec.$3));

  Parser<TagValue> tagRaw() => ref0(token).map((k) => TagValue(k));

  Parser<String> prefix() => [char('-'), char('~')].toChoiceParser().plus().map(
    (chars) => Set.from(chars)
        .toList()
        .sorted(
          (a, b) => a == '~'
              ? b == '~'
                    ? 0
                    : -1
              : 1,
        )
        .join(),
  );

  Parser<String> key() =>
      whitespace().or(char(':')).neg().plus().flatten().trim();

  Parser<String> token() => whitespace().neg().plus().flatten();

  Parser<String> value() => [ref0(quoteValue), ref0(rawValue)].toChoiceParser();

  Parser<String> rawValue() => ref0(token);

  Parser<String> quoteValue() => (
    char('"'),
    [
      (char(r'\'), char('"')).toSequenceParser().map((rec) => rec.$2),
      any(),
    ].toChoiceParser().starLazy(char('"')).map((list) => list.join()),
    char('"'),
  ).toSequenceParser().map((rec) => rec.$2);
}
