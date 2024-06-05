import 'package:e1547/markup/markup.dart';
import 'package:petitparser/petitparser.dart';

class DTextGrammar extends GrammarDefinition<DTextElement> {
  @override
  Parser<DTextElement> start() => body().end();

  Parser<DTextElement> body([Parser<void>? limit]) => ref1(
        trimmed,
        condense(
          (
            ref0(structures).optional(),
            ref2(
              withText,
              [
                ref0(newlineStructures),
                ref0(blocks),
                ref0(textElement),
              ].toChoiceParser(),
              limit,
            ),
          ).toSequenceParser().map(
                (e) => DTextElements([
                  if (e.$1 != null) e.$1!,
                  e.$2,
                ]),
              ),
        ),
      );

  Parser<DTextElement> withText([
    Parser<DTextElement>? other,
    Parser<void>? limit,
  ]) =>
      condense(
        [
          if (other != null) other,
          ref0(character),
        ]
            .toChoiceParser()
            .starLazy(limit ?? endOfInput())
            .map(DTextElements.new),
      );

  Parser<DTextElement> trimmed(Parser<DTextElement> parser) {
    return parser.map((l) {
      DTextElement trim(DTextElement element, [bool? left]) {
        if (element is DTextContent) {
          String text = element.content;
          if (left == null) {
            return DTextContent(text.trim());
          } else if (left) {
            return DTextContent(text.trimLeft());
          } else {
            return DTextContent(text.trimRight());
          }
        } else if (element is DTextElements) {
          List<DTextElement> elements = element.elements;
          if (elements.isEmpty) return element;
          if (left == null) {
            DTextElement first = elements.first;
            DTextElement last = elements.last;
            if (first == last) return trim(first);
            elements.remove(first);
            elements.remove(last);
            return DTextElements([
              trim(first, true),
              ...elements,
              trim(last, false),
            ]);
          } else if (left) {
            DTextElement first = elements.first;
            elements.remove(first);
            return DTextElements([
              trim(first, true),
              ...elements,
            ]);
          } else {
            DTextElement last = elements.last;
            elements.remove(last);
            return DTextElements([
              ...elements,
              trim(last, false),
            ]);
          }
        }
        return element;
      }

      return trim(l);
    });
  }

  DTextElement condenseDText(DTextElement element) {
    if (element is DTextElements) {
      List<DTextElement> result = [];

      StringBuffer bread = StringBuffer();
      void bake() {
        if (bread.isEmpty) return;
        result.add(DTextContent(bread.toString()));
        bread.clear();
      }

      for (DTextElement child in element.elements) {
        DTextElement output = condenseDText(child);
        if (output is DTextContent) {
          bread.write(output.content);
        } else if (output is DTextElements) {
          bake();
          result.addAll(output.elements);
        } else {
          bake();
          result.add(output);
        }
      }

      bake();

      if (result.length == 1) {
        return result.first;
      } else {
        return DTextElements(result);
      }
    }
    return element;
  }

  Parser<DTextElement> condense(Parser<DTextElement> parser) =>
      parser.map(condenseDText);

  Parser<DTextElement> blocks() => [
        ref0(quote),
        ref0(code),
        ref0(section),
      ].toChoiceParser();

  Parser<void> blockMarkers() => [
        ref1(blockMarker, 'quote'),
        ref1(blockMarker, 'code'),
        ref1(blockMarker, 'section'),
      ].toChoiceParser();

  Parser<DTextElement> structures() => [
        ref0(header),
        ref0(list),
      ].toChoiceParser();

  Parser<DTextElement> newlineStructures() => (
        newline().map(DTextContent.new),
        ref0(structures),
      ).toSequenceParser().map((e) => DTextElements([e.$1, e.$2]));

  Parser<DTextElement> textElement() => [
        ref0(styles),
        ref0(links),
        ref0(character),
      ].toChoiceParser();

  Parser<DTextElement> styles() => [
        ref0(inlineStyles),
        ref0(spoiler),
        ref0(inlineCode),
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

  Parser<void> blockMarker(String tag) => (
        char('['),
        char('/').optional(),
        stringIgnoreCase(tag),
        (char('='), any().starLazy(char(']')).flatten())
            .toSequenceParser()
            .optional(),
        char(']'),
      ).toSequenceParser();

  Parser<DTextElement> simpleBlockTag(String tag) =>
      ref3(blockTag, tag, tag, null).map((e) => e.$2);

  Parser<(String, DTextElement)> blockTag(
    String start,
    String end,
    Parser<DTextElement>? inner,
  ) {
    Parser<void> limit = stringIgnoreCase('[/$end]') | endOfInput();
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
        inner?.starLazy(limit).map<DTextElement>((e) => DTextElements(e)) ??
            ref1(body, limit),
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
          any().map(DTextContent.new),
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
      (position(), ref1(simpleBlockTag, 'spoiler'), position())
          .toSequenceParser()
          .map((e) => DTextSpoiler(DTextId(start: e.$1, end: e.$3), e.$2));
  Parser<DTextElement> color() =>
      ref3(blockTag, 'color', 'color', null).map((e) => DTextColor(e.$1, e.$2));

  Parser<DTextElement> inlineCode() => (
        char('`'),
        any().starLazy(char('`')).flatten().map((e) => DTextInlineCode(e)),
        char('`')
      ).toSequenceParser().map((e) => e.$2);

  Parser<DTextElement> header() => (
        (
          char(' ').star(),
          charIgnoringCase('h'),
          pattern('1-6').map(int.parse),
          char('.'),
          char(' ').star(),
        ).toSequenceParser().map((e) => e.$3),
        condense(
          ref0(textElement)
              .starLazy([
                blockMarkers(),
                newline(),
                endOfInput(),
              ].toChoiceParser())
              .map(DTextElements.new),
        ),
      ).toSequenceParser().map((e) => DTextHeader(e.$1, e.$2));

  Parser<DTextBullet> bullet() => (
        (
          char('*').plus().flatten().map((e) => e.length - 1),
          char(' '),
        ).toSequenceParser().map((e) => e.$1),
        condense(
          ref0(textElement)
              .starLazy([
                blockMarkers(),
                newline(),
                endOfInput(),
              ].toChoiceParser())
              .map(
                (e) => DTextElements(e),
              ),
        ),
      ).toSequenceParser().map((e) => DTextBullet(e.$1, e.$2));

  Parser<DTextElement> list() => (
        ref0(bullet),
        (newline(), ref0(bullet)).toSequenceParser().map((e) => e.$2).star(),
      ).toSequenceParser().map((e) => DTextList([e.$1, ...e.$2]));

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
        (e) => DTextLinkWord(
          LinkWord.values.asNameMap()[e.$1.toLowerCase()]!,
          e.$3,
        ),
      );

  Parser<void> linkEnd() =>
      pattern('.,;:!?")').optional() &
      [
        whitespace(),
        newline(),
        endOfInput(),
      ].toChoiceParser();

  Parser<String> url(Parser<String> startParser) {
    Parser<String> enclosurePair(String open, String close) => (
          char(open),
          (
            startParser,
            any().starLazy(char(close) | ref0(linkEnd)),
          ).toSequenceParser().flatten(),
          char(close)
        ).toSequenceParser().map((e) => e.$2);

    return [
      enclosurePair('<', '>'),
      enclosurePair('[', ']'),
      (
        startParser,
        any().starLazy(ref0(linkEnd)),
      ).toSequenceParser().flatten(),
    ].toChoiceParser();
  }

  Parser<DTextElement> link() => (
        (
          char('"'),
          ref2(withText, ref0(inlineStyles), char('"')),
          char('"'),
          char(':'),
        ).toSequenceParser().map((e) => e.$2).optional(),
        url(
          (
            stringIgnoreCase('http'),
            stringIgnoreCase('s').optional(),
            stringIgnoreCase('://'),
          ).toSequenceParser().flatten(),
        ),
      ).toSequenceParser().map((e) => DTextLink(e.$1, e.$2));

  Parser<DTextElement> localLink() => (
        (
          char('"'),
          ref2(withText, ref0(inlineStyles), char('"')),
          char('"'),
          char(':'),
        ).toSequenceParser().map((e) => e.$2),
        url(
          (
            char('/'),
            any().starLazy(ref0(linkEnd)).flatten(),
          ).toSequenceParser().flatten(),
        ),
      ).toSequenceParser().map((e) => DTextLocalLink(e.$1, e.$2));

  Parser<DTextElement> tagLink() => (
        string('[['),
        any().starLazy(char('|').and() | string(']]')).flatten(),
        (
          char('|'),
          any().starLazy(string(']]')).flatten(),
        ).toSequenceParser().map((e) => e.$2).optional(),
        string(']]'),
      ).toSequenceParser().map((e) => DTextTagLink(e.$3, e.$2));

  Parser<DTextElement> tagSearchLink() => (
        string('{{'),
        any().starLazy(string('}}')).flatten(),
        string('}}'),
      ).toSequenceParser().map((e) => DTextTagSearchLink(e.$2));
}
