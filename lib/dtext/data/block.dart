import 'package:e1547/dtext/dtext.dart';
import 'package:flutter/material.dart';

final DTextParser blockParser = DTextParser.builder(
  regex: TextTag.toRegex(),
  tranformer: (context, match, state) {
    TextTag? tag = TextTag.fromMatch(match);
    String after = tag.after;
    TextBlock? block = TextBlock.values.asNameMap()[tag.key];

    if (block != null) {
      if (!tag.active) {
        return DTextParserResult(
          span: const TextSpan(),
          text: after,
          state: state,
        );
      }

      List<TextTag> others = TextTag.allMatches(after, name: tag.key);

      TextTag? end;

      int openTagCounter = 0;
      for (final other in others) {
        if (other.active) {
          openTagCounter++;
        } else {
          openTagCounter--;
        }
        if (openTagCounter == -1) {
          end = other;
          break;
        }
      }

      String between;

      if (end != null) {
        between = end.before;
        after = end.after;
      } else {
        between = after;
        after = '';
      }

      between = between.replaceAllMapped(RegExp(r'(^\n+)|(\n+$)'), (_) => '');

      Widget blocked;

      switch (block) {
        case TextBlock.spoiler:
          blocked = SpoilerWrap(
            child: Text.rich(parseDText(context, between, state)),
          );
          break;
        case TextBlock.code:
          blocked = QuoteWrap(
            child: Text.rich(
              plainText(context: context, text: between, state: state),
            ),
          );
          break;
        case TextBlock.section:
          blocked = SectionWrap(
            title: tag.value,
            expanded: tag.expanded,
            child: Text.rich(parseDText(context, between, state)),
          );
          break;
        case TextBlock.quote:
          blocked = QuoteWrap(
            child: Text.rich(parseDText(context, between, state)),
          );
          break;
      }

      after = after.replaceAllMapped(RegExp(r'^[ \n]*'), (_) => '');

      return DTextParserResult(
        span: WidgetSpan(
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
            child: blocked,
          ),
        ),
        text: after,
        state: state,
      );
    } else {
      return null;
    }
  },
);

final DTextParser tagParser = DTextParser.builder(
  regex: TextTag.toRegex(),
  tranformer: (context, match, state) {
    TextTag? tag = TextTag.fromMatch(match);
    String after = tag.after;
    TextStateTag? stateTag = TextStateTag.values.asNameMap()[tag.key];

    if (stateTag != null) {
      TextState updated = state.copyWith();
      // add textStyle
      switch (stateTag) {
        case TextStateTag.b:
          updated.bold = tag.active;
          break;
        case TextStateTag.i:
          updated.italic = tag.active;
          break;
        case TextStateTag.u:
          updated.underline = tag.active;
          break;
        case TextStateTag.o:
          // not supported on the site.
          // updated.overline = active;
          break;
        case TextStateTag.s:
          updated.strikeout = tag.active;
          break;
        case TextStateTag.color:
          // I cannot be bothered.
          break;
        case TextStateTag.sup:
          // I have no idea how to implement this.
          break;
        case TextStateTag.sub:
          // I have no idea how to implement this.
          break;
      }

      return DTextParserResult(
          span: const TextSpan(), text: after, state: updated);
    } else {
      return null;
    }
  },
);
