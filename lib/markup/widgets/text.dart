import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/markup/markup.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petitparser/core.dart';
import 'package:username_generator/username_generator.dart';

class DText extends StatefulWidget {
  const DText(
    this.data, {
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
  final String data;
  final TextAlign textAlign;
  final bool softWrap;

  @override
  State<DText> createState() => _DTextState();
}

class _DTextState extends State<DText> {
  List<DTextElement>? elements;
  Object? error;

  void _runParse() {
    try {
      elements = DTextGrammar().build().parse(widget.data).value;
    } on ParserException catch (e) {
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
    if (oldWidget.data != widget.data) {
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
          Text(
            'DText parsing has failed',
            style: TextStyle(color: errorColor),
          ),
        ],
      );
    }

    return LinkPreviewProvider(
      child: SelectionArea(
        child: DTextBody(
          elements: elements!,
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
    required this.elements,
    this.style,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.textAlign = TextAlign.start,
    this.softWrap = true,
  });

  final List<DTextElement> elements;
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
        ?.map((e) => switch (e) {
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
            })
        .toList();
  }

  List<DTextElement> trimElements(List<DTextElement> elements) {
    if (elements.isEmpty) {
      return elements;
    }
    if (elements.first is DTextContent) {
      elements.first = DTextContent(
        (elements.first as DTextContent)
            .content
            .replaceAllMapped(RegExp(r'^\n+'), (_) => '')
            .trimLeft(),
      );
    }
    if (elements.last is DTextContent) {
      elements.last = DTextContent(
        (elements.last as DTextContent)
            .content
            .replaceAllMapped(RegExp(r'\n+$'), (_) => '')
            .trimRight(),
      );
    }
    return elements;
  }

  Widget _buildInner(BuildContext context, List<DTextElement> elements) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.noScaling,
      ),
      child: DTextBody(
        elements: elements,
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
        spans: _buildSpans(context, element.children),
        recognizer: spoilerController.recognizer(element.id),
      ),
      style: TextStyle(
        color: hidden ? Colors.transparent : null,
        backgroundColor: hidden
            ? Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(1)
            : Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.1),
      ),
    );
  }

  InlineSpan _buildLink({
    required BuildContext context,
    List<DTextElement>? name,
    required String link,
    bool? local,
  }) {
    local ??= false;
    VoidCallback action = () => launch(link);
    Uri uri = Uri.parse(link);
    // TODO: this should not be hardcoded
    bool home = ['e621.net', 'e926.net'].contains(uri.host);
    if (local || home) {
      VoidCallback? linkAction =
          const E621LinkParser().parseOnTap(context, link);
      if (linkAction != null) {
        action = linkAction;
      } else {
        action = () => launch(context.read<Client>().withHost(link));
      }
    }

    LinkPreviewProviderState preview = LinkPreviewProvider.of(context);
    String previewLink = local ? context.read<Client>().withHost(link) : link;

    UsernameGenerator? usernameGenerator = context.watch<UsernameGenerator?>();
    RegExp userRegex = RegExp(r'/user(s|/show)/(?<id>\d+)');
    RegExpMatch? match = userRegex.firstMatch(link);
    if (usernameGenerator != null && match != null) {
      name = [
        DTextContent(
          usernameGenerator.generate(int.parse(match.namedGroup('id')!)),
        ),
      ];
    }

    return TextSpan(
      children: wrapWithGesture(
        spans: name != null
            ? _buildSpans(context, name)
            : [TextSpan(text: linkToDisplay(link))],
        recognizer: TapGestureRecognizer()..onTap = action,
        onEnter: (_) => preview.showLink(previewLink),
        onExit: (_) => preview.hideLink(),
      ),
      style: TextStyle(
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  InlineSpan _buildSpan(BuildContext context, DTextElement element) {
    return switch (element) {
      DTextContent() => TextSpan(text: element.content),
      DTextSection() => WidgetSpan(
          child: SectionWrap(
            key: ValueKey(element.id),
            title: element.title,
            expanded: element.expanded,
            child: _buildInner(context, trimElements(element.children)),
          ),
        ),
      DTextQuote() => WidgetSpan(
          child: QuoteWrap(
            child: _buildInner(context, trimElements(element.children)),
          ),
        ),
      DTextCode() => WidgetSpan(
          child: CodeWrap(
            child: _buildInner(context, trimElements(element.children)),
          ),
        ),
      DTextBold() => TextSpan(
          children: _buildSpans(context, element.children),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      DTextItalic() => TextSpan(
          children: _buildSpans(context, element.children),
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
      DTextOverline() => TextSpan(
          children: _buildSpans(context, element.children),
          style: const TextStyle(decoration: TextDecoration.overline),
        ),
      DTextUnderline() => TextSpan(
          children: _buildSpans(context, element.children),
          style: const TextStyle(decoration: TextDecoration.underline),
        ),
      DTextStrikethrough() => TextSpan(
          children: _buildSpans(context, element.children),
          style: const TextStyle(decoration: TextDecoration.lineThrough),
        ),
      DTextSuperscript() => TextSpan(
          children: _buildSpans(context, element.children),
        ),
      DTextSubscript() => TextSpan(
          children: _buildSpans(context, element.children),
        ),
      DTextSpoiler() => _buildSpoiler(context, element),
      DTextColor() => TextSpan(
          children: _buildSpans(context, element.children),
          style: TextStyle(
            color: parseColor(element.color),
          ),
        ),
      DTextInlineCode() => TextSpan(
          text: element.content,
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            backgroundColor: Theme.of(context).cardColor,
          ),
        ),
      DTextHeader() => TextSpan(
          children: [
            if (element.preContent != null)
              _buildSpan(context, element.preContent!),
            ..._buildSpans(context, element.children),
          ],
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize! +
                ((element.level - 7).abs() * 2),
          ),
        ),
      DTextList() => TextSpan(
          children: [
            if (element.preContent != null)
              _buildSpan(context, element.preContent!),
            TextSpan(text: '${' ' * element.indent}• '),
            ..._buildSpans(context, element.children),
          ],
        ),
      DTextLinkWord() => _buildLink(
          context: context,
          name: [DTextContent('${element.type.name} #${element.id}')],
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
          name: [
            DTextContent((element.name ?? element.tag).replaceAll('\n', ' '))
          ],
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
          name: [DTextContent(element.tags.replaceAll('\n', ' '))],
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

  List<InlineSpan> _buildSpans(
    BuildContext context,
    List<DTextElement> elements,
  ) =>
      elements.map((e) => _buildSpan(context, e)).toList();

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: style ?? DefaultTextStyle.of(context).style,
      child: Expandables(
        child: SpoilerProvider(
          builder: (context, child) => Text.rich(
            TextSpan(children: _buildSpans(context, elements)),
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
