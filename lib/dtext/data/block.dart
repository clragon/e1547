import 'package:e1547/dtext/dtext.dart';
import 'package:flutter/material.dart';

InlineSpan parseBlocks(
    BuildContext context, RegExpMatch match, String result, TextState state) {
  List<InlineSpan> spans = [];
  TextTag? tag = TextTag.fromMatch(match);

  String after = tag.after;
  String before = tag.before;

  TextBlock? block = TextBlock.values.asNameMap()[tag.key];
  TextStateTag? stateTag = TextStateTag.values.asNameMap()[tag.key];

  if (block != null && tag.active) {
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

    between = between.replaceAllMapped(blankless, (_) => '');

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
              plainText(context: context, text: between, state: state)),
        );
        break;
      case TextBlock.section:
        blocked = SectionWrap(
          child: Text.rich(parseDText(context, between, state)),
          title: tag.value,
          expanded: tag.expanded,
        );
        break;
      case TextBlock.quote:
        blocked = QuoteWrap(
          child: Text.rich(parseDText(context, between, state)),
        );
        break;
    }

    // remove all the spaces around blocks
    before = before.replaceAllMapped(RegExp(r'[ \n]*$'), (_) => '');
    after = after.replaceAllMapped(RegExp(r'^[ \n]*'), (_) => '');

    spans.addAll([
      parseDText(context, before, state),
      WidgetSpan(
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
          child: blocked,
        ),
      ),
      parseDText(context, after, state),
    ]);
  } else if (stateTag != null) {
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

    spans.addAll([
      parseDText(context, before, state),
      parseDText(context, after, updated),
    ]);
  } else {
    spans.add(parseDText(context, '$before${escape(tag.tag)}$after', state));
  }

  return TextSpan(
    children: spans,
  );
}
