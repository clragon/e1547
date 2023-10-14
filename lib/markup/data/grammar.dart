import 'package:e1547/markup/markup.dart';
import 'package:petitparser/petitparser.dart';

class DTextGrammar extends GrammarDefinition<List<DTextElement>> {
  @override
  Parser<List<DTextElement>> start() => body().end();

  Parser<List<DTextElement>> body([Parser? limit]) =>
      ref2(withText, ref1(element, limit), limit);

  Parser<List<DTextElement>> withText([
    Parser<DTextElement>? other,
    Parser? limit,
  ]) =>
      condense(
        [
          if (other != null) other,
          ref0(character),
        ].toChoiceParser().starLazy(limit ?? endOfInput()),
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

  Parser<DTextElement> element([Parser? limit]) => [
        ref0(blocks),
        ref1(textElement, limit),
      ].toChoiceParser();

  Parser<DTextElement> blocks() => [
        ref0(quote),
        ref0(code),
        ref0(section),
      ].toChoiceParser();

  Parser<DTextElement> textElement([Parser? limit]) => [
        ref1(styles, limit),
        ref0(links),
        ref0(character),
      ].toChoiceParser();

  Parser<DTextElement> styles([Parser? limit]) => [
        ref0(inlineStyles),
        ref0(spoiler),
        ref0(inlineCode),
        ref1(header, limit),
        ref1(list, limit),
      ].toChoiceParser();

  Parser<DTextElement> inlineStyles() => [
        ref0(bold),
        ref0(italic),
        ref0(overline),
        ref0(underline),
        ref0(strikethrough),
        ref0(superscript),
        ref0(subscript),
        ref0(color),
      ].toChoiceParser();

  Parser<DTextElement> links() => [
        ref0(linkWord),
        ref0(link),
        ref0(localLink),
        ref0(tagLink),
        ref0(tagSearchLink),
      ].toChoiceParser();

  Parser<DTextElement> character() => any().map((value) => DTextContent(value));

  Parser<List<DTextElement>> simpleBlockTag(String tag) =>
      ref3(blockTag, tag, tag, null).map((e) => e.$2);

  Parser<(String, List<DTextElement>)> blockTag(
    String start,
    String end,
    Parser<DTextElement>? inner,
  ) {
    Parser limit = stringIgnoreCase('[/$end]') | endOfInput();
    return (
      (
        char('['),
        stringIgnoreCase(start),
        (
          char('='),
          any().starLazy(char(']')).flatten(),
        ).toSequenceParser().optional().map((e) => e?.$2 ?? ''),
        char(']'),
      ).toSequenceParser().map((e) => e.$3),
      (
        inner?.starLazy(limit) ?? ref1(body, limit),
        limit,
      ).toSequenceParser().map((e) => e.$1),
    ).toSequenceParser();
  }

  Parser<DTextElement> quote() =>
      ref1(simpleBlockTag, 'quote').map(DTextQuote.new);
  Parser<DTextElement> code() => ref1(
        condense,
        ref3(
          blockTag,
          'code',
          'code',
          any().map((e) => DTextContent(e)),
        ).map((e) => e.$2),
      ).map(DTextCode.new);

  Parser<DTextElement> section() => (
        position(),
        [
          ref3(blockTag, 'section', 'section', null)
              .map((e) => (e.$1, e.$2, false)),
          ref3(blockTag, 'section,expanded', 'section', null)
              .map((e) => (e.$1, e.$2, true))
        ].toChoiceParser(),
        position(),
      ).toSequenceParser().map((e) {
        final (start, content, end) = e;
        final (tag, children, expanded) = content;
        return DTextSection(
          DTextId(start: start, end: end),
          tag,
          expanded,
          children,
        );
      });

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
      ref3(blockTag, 'color', 'color', null).map((e) => DTextColor(e.$1, e.$2));

  Parser<DTextElement> inlineCode() =>
      (char('`') & any().starLazy(char('`')).flatten() & char('`'))
          .pick(1)
          .map((e) => DTextInlineCode(e));

  Parser<DTextElement> header([Parser? limit]) => (
        startOfLine().map((e) => e != null ? DTextContent(e) : null),
        (
          charIgnoringCase('h'),
          pattern('1-6').map(int.parse),
          char('.'),
          char(' ').optional(),
        ).toSequenceParser().map((e) => e.$2),
        condense(ref0(textElement).starLazy([
          if (limit != null) limit,
          blocks(),
          newline(),
          endOfInput(),
        ].toChoiceParser())),
      ).toSequenceParser().map((e) => DTextHeader(e.$2, e.$1, e.$3));

  Parser<DTextElement> list([Parser? limit]) => (
        startOfLine().map((e) => e != null ? DTextContent(e) : null),
        (
          char('*').plus().flatten().map((e) => e.length - 1),
          char(' '),
        ).toSequenceParser().map((e) => e.$1),
        condense(ref0(textElement).starLazy([
          if (limit != null) limit,
          blocks(),
          newline(),
          endOfInput(),
        ].toChoiceParser())),
      ).toSequenceParser().map((e) => DTextList(e.$2, e.$1, e.$3));

  Parser<DTextElement> linkWord() => LinkWord.values
      .map((e) => e.name)
      .map(
        (e) => (
          stringIgnoreCase(e),
          stringIgnoreCase(' #'),
          digit().plus().flatten().map(int.parse),
        ).toSequenceParser(),
      )
      .toChoiceParser()
      .map(
        (value) => DTextLinkWord(
          LinkWord.values.asNameMap()[value.$1.toLowerCase()]!,
          value.$3,
        ),
      );

  Parser<void> linkEnd() =>
      pattern('.,;:!?")').optional() &
      [
        whitespace(),
        newline(),
        endOfInput(),
      ].toChoiceParser();

  Parser<DTextElement> link() => (
        (
          char('"'),
          ref2(withText, ref0(inlineStyles), char('"')),
          char('"'),
          char(':'),
        ).toSequenceParser().map((e) => e.$2).optional(),
        (
          stringIgnoreCase('http'),
          stringIgnoreCase('s').optional(),
          stringIgnoreCase('://'),
          any().starLazy(ref0(linkEnd)).flatten(),
        ).toSequenceParser().flatten(),
      ).toSequenceParser().map(
            (value) => DTextLink(value.$1, value.$2),
          );

  Parser<DTextElement> localLink() => (
        (
          char('"'),
          ref2(withText, ref0(inlineStyles), char('"')),
          char('"'),
          char(':'),
        ).toSequenceParser().map((e) => e.$2),
        (
          char('/'),
          any().starLazy(ref0(linkEnd)).flatten(),
        ).toSequenceParser().flatten(),
      ).toSequenceParser().map(
            (value) => DTextLocalLink(value.$1, value.$2),
          );

  Parser<DTextElement> tagLink() => (
        string('[['),
        any().starLazy(char('|').and() | string(']]')).flatten(),
        (
          char('|'),
          any().starLazy(string(']]')).flatten(),
        ).toSequenceParser().map((e) => e.$2).optional(),
        string(']]'),
      ).toSequenceParser().map(
            (value) => DTextTagLink(value.$3, value.$2),
          );

  Parser<DTextElement> tagSearchLink() => (
        string('{{'),
        any().starLazy(string('}}')).flatten(),
        string('}}'),
      ).toSequenceParser().map(
            (value) => DTextTagSearchLink(value.$2),
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

Parser<String?> startOfLine() => [
      startOfInput().map((_) => null),
      newline(),
    ].toChoiceParser();
