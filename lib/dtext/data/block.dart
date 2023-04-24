import 'package:e1547/dtext/dtext.dart';
import 'package:e1547/interface/interface.dart';
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

      between = between.trim();

      WidgetBuilder blocked;

      switch (block) {
        case TextBlock.code:
          blocked = (context) => QuoteWrap(
                child: Text.rich(
                  plainText(context: context, text: between, state: state),
                ),
              );
          break;
        case TextBlock.section:
          blocked = (context) => SectionWrap(
                key: ValueKey(after),
                title: tag.value,
                expanded: tag.expanded,
                child: Text.rich(parseDText(context, between, state)),
              );
          break;
        case TextBlock.quote:
          blocked = (context) => QuoteWrap(
                child: Text.rich(parseDText(context, between, state)),
              );
          break;
      }

      after = after.trim();

      return DTextParserResult(
        span: WidgetSpan(
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
            child: Expandables(
              child: SpoilerProvider(
                builder: (context, child) => blocked(context),
              ),
            ),
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
      TextStateStack updated = state;

      TextStateStack withActive<T extends TextState>(bool active, T state) {
        if (tag.active) {
          return updated.push(state);
        } else {
          return updated.pop<T>();
        }
      }

      switch (stateTag) {
        case TextStateTag.b:
          updated = withActive(tag.active, TextStateBold());
          break;
        case TextStateTag.i:
          updated = withActive(tag.active, TextStateItalic());
          break;
        case TextStateTag.u:
          updated = withActive(tag.active, TextStateUnderline());
          break;
        case TextStateTag.o:
          updated = withActive(tag.active, TextStateOverline());
          break;
        case TextStateTag.s:
          updated = withActive(tag.active, TextStateStrikeout());
          break;
        case TextStateTag.color:
          if (tag.active) {
            String? color = tag.value;
            if (color != null) {
              updated = updated.push(TextStateColor(color));
            }
          } else {
            updated = updated.pop<TextStateColor>();
          }
          break;
        case TextStateTag.sup:
          updated = withActive(tag.active, TextStateSuperText());
          break;
        case TextStateTag.sub:
          updated = withActive(tag.active, TextStateSubText());
          break;
        case TextStateTag.spoiler:
          updated = withActive(tag.active, TextStateSpoiler(after));
          break;
      }

      return DTextParserResult(
        span: updated == state
            ? plainText(
                context: context,
                text: tag.tag,
                state: state,
              )
            : const TextSpan(),
        text: after,
        state: updated,
      );
    } else {
      return null;
    }
  },
);
