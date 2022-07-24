import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:e1547/app/data/link.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class _PoolSearchResult {
  final DateTime time;
  final String name;
  final String? thumbnail;
  final String? link;

  const _PoolSearchResult({
    required this.time,
    required this.name,
    this.thumbnail,
    this.link,
  });
}

class PoolSearchInput extends StatefulWidget {
  final PoolsController controller;
  final ActionController actionController;

  const PoolSearchInput({
    super.key,
    required this.controller,
    required this.actionController,
  });

  @override
  State<PoolSearchInput> createState() => _PoolSearchInputState();
}

class _PoolSearchInputState extends State<PoolSearchInput> {
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();
    String text = widget.controller.search.value.trim();
    if (text.isNotEmpty) {
      text = '$text ';
    }
    textController = TextEditingController(text: text);
  }

  @override
  Widget build(BuildContext context) {
    return ControlledTextWrapper(
      textController: textController,
      submit: (value) => widget.controller.search.value = value.trim(),
      actionController: widget.actionController,
      builder: (context, controller, submit) => SearchInput<_PoolSearchResult>(
        submit: submit,
        controller: controller,
        labelText: 'Pool title',
        onSuggestionSelected: (value) {
          if (value.link != null) {
            Navigator.of(context).pop();
            executeLink(context, value.link!);
          } else {
            controller.text = '${value.name} ';
            controller.setFocusToEnd();
          }
        },
        suggestionsCallback: (value) async {
          value = value.trim();
          List<_PoolSearchResult?> entries = [];
          entries.addAll(
            (await context.read<HistoriesService>().getAll(
                      linkRegex: r'/pools' +
                          RegExp.escape(Uri(queryParameters: {
                            r'search[name_matches]': '',
                          }).toString()) +
                          r'=' +
                          queryDivider +
                          r'*' +
                          RegExp.escape(Uri.encodeQueryComponent(value)) +
                          queryDivider +
                          r'*',
                    ))
                .map((e) {
              String? name = parseLink(e.link)?.search;
              if (name != null) {
                return _PoolSearchResult(time: e.visitedAt, name: name);
              }
              return null;
            }).take(4),
          );
          entries.addAll((await context.read<HistoriesService>().getAll(
                    linkRegex: r'/pools/.*',
                    titleRegex: r'.*' +
                        RegExp.escape(value.replaceAll(' ', '_')) +
                        r'.*',
                  ))
              .map((e) {
            String? name = e.title;
            if (name != null) {
              return _PoolSearchResult(
                time: e.visitedAt,
                name: name.replaceAll('_', ' '),
                thumbnail: e.thumbnails.isNotEmpty ? e.thumbnails.first : null,
                link: e.link,
              );
            }
            return null;
          }).take(4));
          Map<String, _PoolSearchResult> results = {};
          for (final result
              in entries.whereNotNull().cast<_PoolSearchResult>()) {
            _PoolSearchResult? old = results[result.name];
            if (old == null) {
              results[result.name] = result;
            } else if (old.link == null && result.link != null) {
              results[result.name] = result;
            } else if (result.link != null && old.time.isBefore(result.time)) {
              results[result.name] = result;
            }
          }
          return results.values
              .sorted((a, b) => b.time.compareTo(a.time))
              .toList()
              .take(4);
        },
        itemBuilder: (context, value) => ListTile(
          title: Text(value.name),
          leading: value.thumbnail != null
              ? Padding(
                  padding: const EdgeInsets.all(4),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: CachedNetworkImage(
                        imageUrl: value.thumbnail!,
                        errorWidget: defaultErrorBuilder,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(value.link != null
                      ? Icons.open_in_new
                      : Icons.lightbulb_outline),
                ),
        ),
      ),
    );
  }
}
