import 'package:e1547/denylist/denylist.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:flutter/material.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({
    required this.controller,
    required this.appBar,
    this.displayType,
    this.drawerActions,
    this.canSelect = true,
  });

  final PostsController controller;
  final PreferredSizeWidget appBar;
  final List<Widget>? drawerActions;
  final PostDisplayType? displayType;
  final bool canSelect;

  @override
  State<StatefulWidget> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  @override
  Widget build(BuildContext context) {
    Widget? floatingActionButton() {
      if (widget.controller.canSearch) {
        return PostsPageFloatingActionButton(controller: widget.controller);
      } else {
        return null;
      }
    }

    Widget? endDrawer() {
      return ContextDrawer(
        title: const Text('Posts'),
        children: [
          CrossFade.builder(
            showChild: widget.drawerActions?.isNotEmpty ?? false,
            builder: (context) => Column(
              children: [
                ...widget.drawerActions!,
                const Divider(),
              ],
            ),
          ),
          if (widget.controller.filterMode != PostFilterMode.unavailable)
            DrawerDenySwitch(controller: widget.controller),
          DrawerTagCounter(controller: widget.controller),
        ],
      );
    }

    return ChangeNotifierProvider.value(
      value: widget.controller,
      child: Consumer<PostsController>(
        builder: (context, controller, child) => SelectionLayout<Post>(
          enabled: widget.canSelect,
          items: controller.items,
          child: RefreshableDataPage.builder(
            appBar: PostSelectionAppBar(
              controller: widget.controller,
              child: widget.appBar,
            ),
            drawer: const RouterDrawer(),
            endDrawer: endDrawer(),
            floatingActionButton: floatingActionButton(),
            builder: (context, child) =>
                LimitedWidthLayout(child: TileLayout(child: child)),
            controller: widget.controller,
            child: (context) => postDisplay(
              context: context,
              controller: widget.controller,
              displayType: widget.displayType ?? PostDisplayType.grid,
            ),
          ),
        ),
      ),
    );
  }
}

class PostsPageFloatingActionButton extends StatelessWidget {
  const PostsPageFloatingActionButton({
    super.key,
    required this.controller,
  });

  final PostsController controller;

  @override
  Widget build(BuildContext context) {
    return SearchPromptFloationgActionButton(
      tags: controller.query,
      onSubmit: (value) => controller.query = value,
      filters: [
        PrimaryFilterConfig(
          filter: TagSearchFilterTag(
            tag: 'tags',
            name: 'Tags',
          ),
          filters: [
            NestedFilterTag(
              tag: 'tags',
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

class TagSearchFilterTag extends BuilderFilterTag {
  TagSearchFilterTag({
    required super.tag,
    super.name,
  }) : super(
          builder: (context, state) => TagSearchFilter(state: state),
        );
}

class TagSearchFilter extends StatelessWidget {
  const TagSearchFilter({
    super.key,
    required this.state,
  });

  final FilterTagState state;

  @override
  Widget build(BuildContext context) {
    FilterTagThemeData theme = FilterTagTheme.of(context);
    return SubTextValue(
      value: state.value,
      onChanged: (value) => state.onChanged(QueryMap.parse(value).toString()),
      shouldUpdate: (oldValue, newValue) =>
          QueryMap.parse(oldValue).toString() != newValue,
      builder: (context, controller) => TagInput(
        textInputAction: TextInputAction.search,
        direction: AxisDirection.up,
        labelText: state.filter.name,
        decoration: theme.decoration,
        focusNode: theme.focusNode,
        controller: controller,
        submit: (value) => state.onSubmit?.call(value),
      ),
    );
  }
}
