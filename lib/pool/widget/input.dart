import 'package:cached_network_image/cached_network_image.dart';
import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/history/history.dart';
import 'package:e1547/pool/data/controller.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class PoolsPageFloatingActionButton extends StatelessWidget {
  const PoolsPageFloatingActionButton({super.key, required this.controller});

  final PoolController controller;

  @override
  Widget build(BuildContext context) {
    return SearchPromptFloatingActionButton(
      tags: controller.query,
      onSubmit: (value) => controller.query = value,
      filters: [
        WrapperFilterConfig(
          wrapper: (value) => 'search[$value]',
          unwrapper: (value) => value.substring(7, value.length - 1),
          filters: [
            PrimaryFilterConfig(
              filter: PoolNameFilterTag(tag: 'name_matches'),
              filters: const [
                TextFilterTag(
                  tag: 'description_matches',
                  name: 'Description',
                  icon: Icon(Icons.description),
                ),
                TextFilterTag(
                  tag: 'creator_name',
                  name: 'Creator',
                  icon: Icon(Icons.person),
                ),
                ToggleFilterTag(
                  tag: 'is_active',
                  name: 'Active',
                  enabled: 'true',
                  disabled: 'false',
                  description: 'Is active',
                ),
                ChoiceFilterTag(
                  tag: 'category',
                  name: 'Category',
                  icon: Icon(Icons.category),
                  options: [
                    ChoiceFilterTagValue(value: null, name: 'Default'),
                    ChoiceFilterTagValue(value: 'series', name: 'Series'),
                    ChoiceFilterTagValue(
                      value: 'collection',
                      name: 'Collection',
                    ),
                  ],
                ),
                ChoiceFilterTag(
                  tag: 'order',
                  name: 'Sort by',
                  icon: Icon(Icons.sort),
                  options: [
                    ChoiceFilterTagValue(value: null, name: 'Default'),
                    ChoiceFilterTagValue(value: 'name', name: 'Name'),
                    ChoiceFilterTagValue(value: 'created_at', name: 'Created'),
                    ChoiceFilterTagValue(value: 'updated_at', name: 'Updated'),
                    ChoiceFilterTagValue(
                      value: 'post_count',
                      name: 'Post count',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _PoolSearchResult {
  const _PoolSearchResult({
    required this.time,
    required this.name,
    this.thumbnail,
    this.link,
  });

  final DateTime time;
  final String name;
  final String? thumbnail;
  final String? link;
}

class PoolNameFilterTag extends BuilderFilterTag {
  PoolNameFilterTag({required super.tag, super.name})
    : super(builder: (context, state) => PoolNameFilter(state: state));
}

class PoolNameFilter extends StatelessWidget {
  const PoolNameFilter({super.key, required this.state});

  final FilterTagState state;

  @override
  Widget build(BuildContext context) {
    FilterTagThemeData theme = FilterTagTheme.of(context);
    return SubTextValue(
      value: state.value,
      onChanged: state.onChanged,
      builder: (context, controller) =>
          AutocompleteTextField<_PoolSearchResult>(
            direction: VerticalDirection.up,
            submit: (value) => state.onSubmit?.call(value),
            controller: controller,
            labelText: 'Pool title',
            decoration: theme.decoration,
            focusNode: theme.focusNode,
            onSelected: (value) {
              if (value.link != null) {
                Navigator.of(context).pop();
                const E621LinkParser().open(context, value.link!);
              } else {
                controller.text = '${value.name} ';
                controller.setFocusToEnd();
              }
            },
            suggestionsCallback: (value) async {
              value = value.trim();
              final client = context.read<Client>();
              return (await client.histories.page(
                    page: 1,
                    query: HistoryQuery(
                      date: DateTime.now(),
                      link: r'/pools/.*',
                      title:
                          r'.*' +
                          RegExp.escape(value.replaceAll(' ', '_')) +
                          r'.*',
                    ),
                    limit: 4,
                  ))
                  .where((e) => e.title != null)
                  .map(
                    (e) => _PoolSearchResult(
                      time: e.visitedAt,
                      name: e.title!.replaceAll('_', ' '),
                      thumbnail: e.thumbnails.isNotEmpty
                          ? e.thumbnails.first
                          : null,
                      link: e.link,
                    ),
                  )
                  .toList();
            },
            itemBuilder: (context, value) => ListTile(
              title: Text(value.name),
              leading: value.thumbnail != null
                  ? Padding(
                      padding: const EdgeInsets.all(4),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(4),
                        ),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: CachedNetworkImage(
                            imageUrl: value.thumbnail!,
                            errorWidget: defaultErrorBuilder,
                            fit: BoxFit.cover,
                            cacheManager: context.read<BaseCacheManager>(),
                          ),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        value.link != null
                            ? Icons.open_in_new
                            : Icons.lightbulb_outline,
                      ),
                    ),
            ),
          ),
    );
  }
}
