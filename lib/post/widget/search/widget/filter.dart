import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class PostsPageFloatingActionButton extends StatelessWidget {
  const PostsPageFloatingActionButton({super.key, required this.controller});

  final PostController controller;

  @override
  Widget build(BuildContext context) {
    return SearchPromptFloatingActionButton(
      tags: controller.query,
      onSubmit: (value) => controller.query = value,
      filters: [
        PrimaryFilterConfig(
          filter: TagSearchFilterTag(tag: 'tags', name: 'Tags'),
          filters: [
            NestedFilterTag(
              tag: 'tags',
              decode: TagMap.new,
              encode: (value) => TagMap.from(value).toString(),
              filters: const [
                NumberRangeFilterTag(
                  tag: 'score',
                  name: 'Score',
                  min: 0,
                  max: 100,
                  division: 10,
                  initial: NumberRange(
                    20,
                    comparison: NumberComparison.greaterThanOrEqual,
                  ),
                  icon: Icon(Icons.arrow_upward),
                ),
                NumberRangeFilterTag(
                  tag: 'favcount',
                  name: 'Favorite count',
                  min: 0,
                  max: 100,
                  division: 10,
                  initial: NumberRange(
                    20,
                    comparison: NumberComparison.greaterThanOrEqual,
                  ),
                  icon: Icon(Icons.favorite),
                ),
                ChoiceFilterTag(
                  tag: 'order',
                  name: 'Sort by',
                  icon: Icon(Icons.sort),
                  options: [
                    ChoiceFilterTagValue(value: null, name: 'Default'),
                    ChoiceFilterTagValue(value: 'new', name: 'New'),
                    ChoiceFilterTagValue(value: 'score', name: 'Score'),
                    ChoiceFilterTagValue(value: 'favcount', name: 'Favorites'),
                    ChoiceFilterTagValue(value: 'rank', name: 'Rank'),
                    ChoiceFilterTagValue(value: 'random', name: 'Random'),
                  ],
                ),
                ChoiceFilterTag(
                  tag: 'rating',
                  name: 'Rating',
                  icon: Icon(Icons.question_mark),
                  options: [
                    ChoiceFilterTagValue(value: null, name: 'All'),
                    ChoiceFilterTagValue(value: 's', name: 'Safe'),
                    ChoiceFilterTagValue(value: 'q', name: 'Questionable'),
                    ChoiceFilterTagValue(value: 'e', name: 'Explicit'),
                  ],
                ),
                ToggleFilterTag(
                  tag: 'inpool',
                  name: 'Pool',
                  enabled: 'true',
                  disabled: 'false',
                  description: 'Has pool',
                ),
                ToggleFilterTag(
                  tag: 'ischild',
                  name: 'Child',
                  enabled: 'true',
                  disabled: 'false',
                  description: 'Is child post',
                ),
                ToggleFilterTag(
                  tag: 'isparent',
                  name: 'Parent',
                  enabled: 'true',
                  disabled: 'false',
                  description: 'Is parent post',
                ),
                ChoiceFilterTag(
                  tag: 'date',
                  name: 'Upload date',
                  icon: Icon(Icons.date_range),
                  options: [
                    ChoiceFilterTagValue(value: null, name: 'All'),
                    ChoiceFilterTagValue(value: 'day', name: 'Last day'),
                    ChoiceFilterTagValue(value: 'week', name: 'Last week'),
                    ChoiceFilterTagValue(value: 'month', name: 'Last Month'),
                    ChoiceFilterTagValue(value: 'year', name: 'Last Year'),
                  ],
                ),
                ChoiceFilterTag(
                  tag: 'status',
                  name: 'Status',
                  icon: Icon(Icons.help),
                  options: [
                    ChoiceFilterTagValue(value: null, name: 'Default'),
                    ChoiceFilterTagValue(value: 'active', name: 'Active'),
                    ChoiceFilterTagValue(value: 'pending', name: 'Pending'),
                    ChoiceFilterTagValue(value: 'deleted', name: 'Deleted'),
                    ChoiceFilterTagValue(value: 'flagged', name: 'Flagged'),
                    ChoiceFilterTagValue(value: 'any', name: 'Any'),
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
