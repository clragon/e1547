import 'package:e1547/markup/markup.dart';
import 'package:petitparser/petitparser.dart';

class DTextGrammar extends GrammarDefinition<List<DTextElement>> {
  @override
  Parser<List<DTextElement>> start() => body().end();

  Parser<List<DTextElement>> body([Parser? end]) =>
      ref2(withText, ref0(element), end);

  Parser<List<DTextElement>> withText(
          [Parser<DTextElement>? other, Parser? end]) =>
      condense(
        <Parser>[
          if (other != null) other,
          ref0(character),
        ].toChoiceParser().cast<DTextElement>().starLazy(end ?? endOfInput()),
      );

  Parser<List<DTextElement>> condense(Parser<List<DTextElement>> parser) =>
      parser.map((l) => l.fold(<DTextElement>[], (l, e) {
            DTextElement current = e;
            DTextElement? previous = l.lastOrNull;
            if (current is DTextContent && previous is DTextContent) {
              return [...l.take(l.length - 1), previous + current];
            } else {
              return [...l, current];
            }
          }).toList());

  Parser<DTextElement> element() => (ref0(blocks) | ref0(textElement)).cast();

  Parser<DTextElement> blocks() =>
      (ref0(quote) | ref0(code) | ref0(section)).cast();

  Parser<DTextElement> textElement() =>
      (ref0(styles) | ref0(links) | ref0(character)).cast();

  Parser<DTextElement> styles() => (ref0(inlineStyles) |
          ref0(spoiler) |
          ref0(inlineCode) |
          ref0(header) |
          ref0(list))
      .cast();

  Parser<DTextElement> inlineStyles() => (ref0(bold) |
          ref0(italic) |
          ref0(overline) |
          ref0(underline) |
          ref0(strikethrough) |
          ref0(superscript) |
          ref0(subscript) |
          ref0(color))
      .cast();

  Parser<DTextElement> links() =>
      (ref0(linkWord) | ref0(link) | ref0(localLink) | ref0(tagLink)).cast();

  Parser<DTextElement> character() => any().map((value) => DTextContent(value));

  Parser<List<DTextElement>> simpleBlockTag(String tag) =>
      blockTag(tag, tag).pick(1).cast();

  Parser<List<dynamic>> blockTag(
    String start,
    String end,
  ) =>
      [
        [
          char('['),
          stringIgnoreCase(start),
          (char('=') & any().starLazy(char(']')).flatten()).pick(1).optional(),
          char(']'),
        ].toSequenceParser().pick(2),
        [
          ref1(body, stringIgnoreCase('[/$end]')),
          stringIgnoreCase('[/$end]'),
        ].toSequenceParser().pick(0),
      ].toSequenceParser();

  Parser<DTextElement> quote() =>
      ref1(simpleBlockTag, 'quote').map(DTextQuote.new);
  Parser<DTextElement> code() => <Parser>[
        stringIgnoreCase('[code]'),
        any()
            .starLazy(stringIgnoreCase('[/code]'))
            .flatten()
            .map((e) => [DTextContent(e)]),
        stringIgnoreCase('[/code]'),
      ].toSequenceParser().pick(1).castList<DTextElement>().map(DTextCode.new);

  Parser<DTextElement> section() => <Parser>[
        position(),
        <Parser>[
          ref2(blockTag, 'section', 'section').map((e) => [...e, false]),
          ref2(blockTag, 'section,expanded', 'section').map((e) => [...e, true])
        ].toChoiceParser(),
        position(),
      ]
          .toSequenceParser()
          .map((e) => DTextSection(
              DTextId(start: e[0], end: e[2]), e[1][0], e[1][2], e[1][1]))
          .cast();

  Parser<DTextElement> bold() => ref1(simpleBlockTag, 'b').map(DTextBold.new);
  Parser<DTextElement> italic() =>
      ref1(simpleBlockTag, 'i').map(DTextItalic.new);
  Parser<DTextElement> overline() =>
      ref1(simpleBlockTag, 'o').map(DTextOverline.new);
  Parser<DTextElement> underline() =>
      ref1(simpleBlockTag, 'u').map(DTextUnderline.new);
  Parser<DTextElement> strikethrough() =>
      ref1(simpleBlockTag, 's').map(DTextStrikethrough.new);
  Parser<DTextElement> superscript() =>
      ref1(simpleBlockTag, 'sup').map(DTextSuperscript.new);
  Parser<DTextElement> subscript() =>
      ref1(simpleBlockTag, 'sub').map(DTextSubscript.new);
  Parser<DTextElement> spoiler() =>
      (position() & ref1(simpleBlockTag, 'spoiler') & position())
          .map((e) => DTextSpoiler(DTextId(start: e[0], end: e[2]), e[1]));
  Parser<DTextElement> color() =>
      ref2(blockTag, 'color', 'color').map((e) => DTextColor(e[0], e[1]));

  Parser<DTextElement> inlineCode() =>
      (char('`') & any().starLazy(char('`')).flatten() & char('`'))
          .pick(1)
          .map((e) => DTextInlineCode(e));

  Parser<DTextElement> header() => <Parser>[
        startOfLine().map((e) => e != null ? DTextContent(e) : null),
        charIgnoringCase('h'),
        pattern('1-6').map(int.parse),
        char('.'),
        char(' ').optional(),
        condense(ref0(textElement).starLazy(newline() | endOfInput())),
      ].toSequenceParser().map((e) => DTextHeader(e[2], e[0], e[5]));

  Parser<DTextElement> list() => <Parser>[
        startOfLine().map((e) => e != null ? DTextContent(e) : null),
        char('*').plus().flatten().map((e) => e.length - 1),
        char(' '),
        ref1(body, (newline() | endOfInput())),
      ].toSequenceParser().map((e) => DTextList(e[1], e[0], e[3]));

  Parser<DTextElement> linkWord() => LinkWord.values
      .map((e) => e.name)
      .map(
        (e) => <Parser>[
          stringIgnoreCase(e),
          stringIgnoreCase(' #'),
          digit().plus().flatten().map(int.parse),
        ].toSequenceParser(),
      )
      .toChoiceParser()
      .map(
        (value) => DTextLinkWord(
          LinkWord.values.asNameMap()[value[0].toLowerCase()]!,
          value[2] as int,
        ),
      );

  Parser<void> linkEnd() =>
      pattern('.,;:!?")').optional() &
      <Parser>[
        whitespace(),
        newline(),
        endOfInput(),
      ].toChoiceParser();

  Parser<DTextElement> link() => <Parser>[
        <Parser>[
          char('"'),
          ref2(withText, ref0(inlineStyles), char('"')),
          char('"'),
          char(':'),
        ].toSequenceParser().pick(1).optional(),
        <Parser>[
          stringIgnoreCase('http'),
          stringIgnoreCase('s').optional(),
          stringIgnoreCase('://'),
          any().starLazy(ref0(linkEnd)).flatten(),
        ].toSequenceParser().flatten(),
      ].toSequenceParser().map(
            (value) => DTextLink(value[0], value[1]),
          );

  Parser<DTextElement> localLink() => <Parser>[
        <Parser>[
          char('"'),
          ref2(withText, ref0(inlineStyles), char('"')),
          char('"'),
          char(':'),
        ].toSequenceParser().pick(1),
        <Parser>[
          char('/'),
          any().starLazy(ref0(linkEnd)).flatten(),
        ].toSequenceParser().flatten(),
      ].toSequenceParser().map(
            (value) => DTextLocalLink(value[0], value[1]),
          );

  Parser<DTextElement> tagLink() => <Parser>[
        string('[['),
        any().starLazy(char('|').and() | string(']]')).flatten(),
        [
          char('|'),
          any().starLazy(string(']]')).flatten(),
        ].toSequenceParser().pick(1).optional(),
        string(']]'),
      ].toSequenceParser().map(
            (value) => DTextTagLink(value[2], value[1]),
          );
}

class StartOfInputParser extends Parser<void> {
  @override
  Result<void> parseOn(Context context) {
    if (context.position == 0) {
      return context.success(null);
    } else {
      return context.failure('Expected start of input');
    }
  }

  @override
  Parser<void> copy() => StartOfInputParser();
}

Parser<void> startOfInput() => StartOfInputParser();

Parser<String?> startOfLine() => (startOfInput() | newline()).cast();
