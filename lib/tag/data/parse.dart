import 'package:e1547/tag/tag.dart';
import 'package:petitparser/petitparser.dart';

class TagGrammarDefinition extends GrammarDefinition<TagNode> {
  @override
  Parser<TagNode> start() => ref0(root).end();

  Parser<TagNode> root() =>
      ref0(tagNode).starSeparated(whitespace().plus()).map((separated) {
        final nodes = separated.elements;
        if (nodes.isEmpty) return const TagGroup(children: []);
        if (nodes.length == 1) return nodes[0];
        return TagGroup(children: nodes);
      });

  Parser<TagNode> tagNode() =>
      (
        ref0(modifier).optional(),
        [ref0(group), ref0(atom)].toChoiceParser(),
      ).toSequenceParser().map(
        (rec) => rec.$2.copyWith(negated: rec.$1?.$1, optional: rec.$1?.$2),
      );

  Parser<(bool, bool)> modifier() =>
      [char('~').map((_) => (false, true)), char('-').map((_) => (true, false))]
          .toChoiceParser()
          .plus()
          .map((list) => (list.any((t) => t.$1), list.any((t) => t.$2)));

  Parser<TagGroup> group() => (
    char('('),
    whitespace(),
    (
      (char(')'), whitespace()).toSequenceParser().not(),
      ref0(tagNode),
      whitespace(),
    ).toSequenceParser().map((rec) => rec.$2).star(),
    whitespace().star(),
    char(')'),
  ).toSequenceParser().map((rec) => TagGroup(children: rec.$3));

  Parser<TagAtom> atom() => (
    ref0(key),
    (char(':'), ref0(value)).toSequenceParser().map((rec) => rec.$2).optional(),
  ).toSequenceParser().map((rec) => TagAtom(rec.$1, rec.$2));

  Parser<String> key() => whitespace().or(char(':')).neg().plus().flatten();

  Parser<String> value() =>
      [ref0(quotedValue), whitespace().neg().plus().flatten()].toChoiceParser();

  Parser<String> quotedValue() => (
    char('"'),
    ([
      (char(r'\'), any()).toSequenceParser().map((rec) => rec.$2),
      any(),
    ].toChoiceParser()).starGreedy(char('"')).map((value) => value.join()),
    char('"'),
  ).toSequenceParser().map((rec) => rec.$2);
}
