import 'package:collection/collection.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/domain/domain.dart';
import 'package:e1547/logs/logs.dart';
import 'package:e1547/markup/markup.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petitparser/core.dart';

class DText extends StatefulWidget {
  const DText(
    this.value, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.textAlign = TextAlign.start,
    this.softWrap = true,
  });

  final TextStyle? style;
  final int? maxLines;
  final TextOverflow overflow;
  final String value;
  final TextAlign textAlign;
  final bool softWrap;

  @override
  State<DText> createState() => _DTextState();
}

class _DTextState extends State<DText> {
  final Logger _logger = Logger('DText');
  DTextElement? content;
  Object? error;

  void _runParse() {
    try {
      content = DTextGrammar().build().parse(widget.value).value;
    } on ParserException catch (e, s) {
      _logger.shout('Failed to parse DText', e, s);
      error = e;
    } on Object catch (e, s) {
      _logger.severe('Catastropically failed to parse DText', e, s);
      error = e;
    }
  }

  @override
  void initState() {
    super.initState();
    _runParse();
  }

  @override
  void didUpdateWidget(covariant DText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _runParse();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      Color errorColor = Theme.of(context).colorScheme.error;
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              Icons.warning_amber_outlined,
              color: errorColor,
              size: 20,
            ),
          ),
          Text('DText parsing has failed', style: TextStyle(color: errorColor)),
        ],
      );
    }

    return LinkPreviewProvider(
      child: SelectionArea(
        child: DTextBody(
          content: content!,
          style: widget.style,
          maxLines: widget.maxLines,
          overflow: widget.overflow,
          textAlign: widget.textAlign,
          softWrap: widget.softWrap,
        ),
      ),
    );
  }
}

class DTextBody extends StatelessWidget {
  const DTextBody({
    super.key,
    required this.content,
    this.style,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.textAlign = TextAlign.start,
    this.softWrap = true,
  });

  final DTextElement content;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow overflow;
  final TextAlign textAlign;
  final bool softWrap;

  /// This is a horrendous hack to make the spoiler work.
  /// GestureRecognizer with TextSpan is a mess.
  /// May god have mercy on my soul.
  List<InlineSpan>? wrapWithGesture({
    required List<InlineSpan>? spans,
    required GestureRecognizer recognizer,
    PointerEnterEventListener? onEnter,
    PointerExitEventListener? onExit,
  }) {
    return spans
        ?.map(
          (e) => switch (e) {
            TextSpan() => TextSpan(
              text: e.text,
              children: wrapWithGesture(
                spans: e.children,
                recognizer: recognizer,
                onEnter: onEnter,
                onExit: onExit,
              ),
              recognizer: e.recognizer ?? recognizer,
              style: e.style,
              onEnter: e.onEnter ?? onEnter,
              onExit: e.onExit ?? onExit,
            ),
            _ => e,
          },
        )
        .toList();
  }

  Widget _buildInner(BuildContext context, DTextElement content) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: DTextBody(
        content: content,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
        softWrap: softWrap,
      ),
    );
  }

  InlineSpan _buildSpoiler(BuildContext context, DTextSpoiler element) {
    SpoilerController spoilerController = context.watch<SpoilerController>();
    spoilerController.register(element.id);
    bool hidden = spoilerController.hidden(element.id);
    return TextSpan(
      children: wrapWithGesture(
        spans: [_buildSpan(context, element.children)],
        recognizer: spoilerController.recognizer(element.id),
      ),
      style: TextStyle(
        color: hidden ? Colors.transparent : null,
        backgroundColor: hidden
            ? Theme.of(context).textTheme.bodyMedium!.color!.withAlpha(255)
            : Theme.of(context).textTheme.bodyMedium!.color!.withAlpha(26),
      ),
    );
  }

  InlineSpan _buildLink({
    required BuildContext context,
    DTextElement? name,
    required String link,
    bool? local,
  }) {
    local ??= false;
    VoidCallback action = () => launch(link);
    Uri? uri = Uri.tryParse(link);
    // TODO: this should not be hardcoded
    bool home = uri != null && ['e621.net', 'e926.net'].contains(uri.host);
    if (local || home) {
      VoidCallback? linkAction = const E621LinkParser().parseOnTap(
        context,
        link,
      );
      if (linkAction != null) {
        action = linkAction;
      } else {
        action = () => launch(context.read<Domain>().withHost(link));
      }
    }

    LinkPreviewProviderState preview = LinkPreviewProvider.of(context);
    String previewLink = local ? context.read<Domain>().withHost(link) : link;

    return TextSpan(
      children: wrapWithGesture(
        spans: [
          if (name != null)
            _buildSpan(context, name)
          else
            TextSpan(text: linkToDisplay(link)),
        ],
        recognizer: TapGestureRecognizer()..onTap = action,
        onEnter: (_) => preview.showLink(previewLink),
        onExit: (_) => preview.hideLink(),
      ),
      style: TextStyle(color: Theme.of(context).colorScheme.secondary),
    );
  }

  InlineSpan _buildSpan(BuildContext context, DTextElement element) {
    return switch (element) {
      DTextElements() => TextSpan(
        children: element.elements.map((e) => _buildSpan(context, e)).toList(),
      ),
      DTextContent() => TextSpan(text: element.content),
      DTextSection() => WidgetSpan(
        child: SectionWrap(
          key: ValueKey(element.id),
          title: element.title,
          expanded: element.expanded,
          child: _buildInner(context, element.children),
        ),
      ),
      DTextQuote() => WidgetSpan(
        child: QuoteWrap(child: _buildInner(context, element.children)),
      ),
      DTextCode() => WidgetSpan(
        child: CodeWrap(child: _buildInner(context, element.children)),
      ),
      DTextBold() => TextSpan(
        children: [_buildSpan(context, element.children)],
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      DTextItalic() => TextSpan(
        children: [_buildSpan(context, element.children)],
        style: const TextStyle(fontStyle: FontStyle.italic),
      ),
      DTextOverline() => TextSpan(
        children: [_buildSpan(context, element.children)],
        style: const TextStyle(decoration: TextDecoration.overline),
      ),
      DTextUnderline() => TextSpan(
        children: [_buildSpan(context, element.children)],
        style: const TextStyle(decoration: TextDecoration.underline),
      ),
      DTextStrikethrough() => TextSpan(
        children: [_buildSpan(context, element.children)],
        style: const TextStyle(decoration: TextDecoration.lineThrough),
      ),
      DTextSuperscript() => TextSpan(
        children: [_buildSpan(context, element.children)],
      ),
      DTextSubscript() => TextSpan(
        children: [_buildSpan(context, element.children)],
      ),
      DTextSpoiler() => _buildSpoiler(context, element),
      DTextColor() => TextSpan(
        children: [_buildSpan(context, element.children)],
        style: TextStyle(color: parseColor(element.color)),
      ),
      DTextInlineCode() => TextSpan(
        text: element.content,
        style: TextStyle(
          fontFamily: 'JetBrains Mono',
          backgroundColor: Theme.of(context).cardColor,
        ),
      ),
      DTextHeader() => TextSpan(
        children: [_buildSpan(context, element.children)],
        style: TextStyle(
          fontSize:
              Theme.of(context).textTheme.bodyMedium!.fontSize! +
              ((element.level - 7).abs() * 2),
        ),
      ),
      DTextList() => TextSpan(
        children: element.items
            .map(
              (e) => [
                if (element.items.indexOf(e) != 0) const TextSpan(text: '\n'),
                _buildSpan(context, e),
              ],
            )
            .flattened
            .toList(),
      ),
      DTextBullet() => TextSpan(
        children: [
          TextSpan(text: '${' ' * element.indent}• '),
          _buildSpan(context, element.children),
        ],
      ),
      DTextLinkWord() => _buildLink(
        context: context,
        name: DTextContent('${element.type.name} #${element.id}'),
        link: element.type.toLink(element.id),
        local: true,
      ),
      DTextLink() => _buildLink(
        context: context,
        name: element.name,
        link: element.link,
      ),
      DTextLocalLink() => _buildLink(
        context: context,
        name: element.name,
        link: element.link,
        local: true,
      ),
      DTextTagLink() => _buildLink(
        context: context,
        name: DTextContent((element.name ?? element.tag).replaceAll('\n', ' ')),
        link: Uri(
          path: '/posts',
          queryParameters: {
            'tags': element.tag
                .replaceAll(' ', '_')
                .replaceAll('\n', ' ')
                .toLowerCase(),
          },
        ).toString(),
        local: true,
      ),
      DTextTagSearchLink() => _buildLink(
        context: context,
        name: DTextContent(element.tags.replaceAll('\n', ' ')),
        link: Uri(
          path: '/posts',
          queryParameters: {
            'tags': element.tags.replaceAll('\n', ' ').toLowerCase(),
          },
        ).toString(),
        local: true,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: style ?? DefaultTextStyle.of(context).style,
      child: Expandables(
        child: SpoilerProvider(
          builder: (context, child) => Text.rich(
            _buildSpan(context, content),
            maxLines: maxLines,
            overflow: overflow,
            textAlign: textAlign,
            softWrap: softWrap,
          ),
        ),
      ),
    );
  }
}
