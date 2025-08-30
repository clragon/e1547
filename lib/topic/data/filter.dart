import 'package:e1547/query/query.dart';
import 'package:e1547/topic/topic.dart';
import 'package:flutter/widgets.dart';

// This is not great. It doesnt allow copying the entire value easily.
typedef TopicFilterValue = ({bool hideTagEditing});

class TopicFilter extends FilterController<Topic>
    implements ValueNotifier<TopicFilterValue> {
  TopicFilter([TopicFilterValue? value])
    : _value = value ?? (hideTagEditing: true);

  TopicFilterValue _value;

  @override
  TopicFilterValue get value => _value;

  @override
  set value(TopicFilterValue value) {
    if (_value == value) return;
    _value = value;
    notifyListeners();
  }

  // TODO: remove this and implement fetching AIBUR inside dtext
  @override
  List<Topic> filter(List<Topic> items) => items
      .where(
        (topic) =>
            !value.hideTagEditing ||
            topic.categoryId !=
                TopicCategory.tagAliasAndImplicationSuggestions.id,
      )
      .toList();
}
