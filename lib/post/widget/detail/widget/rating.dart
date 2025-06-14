import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

extension ExtraRatingData on Rating {
  Widget get icon {
    switch (this) {
      case Rating.s:
        return const Icon(Icons.check);
      case Rating.q:
        return const Icon(Icons.help);
      case Rating.e:
        return const Icon(Icons.warning);
    }
  }

  String get title {
    switch (this) {
      case Rating.s:
        return 'Safe';
      case Rating.q:
        return 'Questionable';
      case Rating.e:
        return 'Explicit';
    }
  }
}

class RatingDisplay extends StatelessWidget {
  const RatingDisplay({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    Rating rating = context.select<PostEditingController?, Rating>(
      (value) => value?.value?.rating ?? post.rating,
    );
    bool canEdit = context.select<PostEditingController?, bool>(
      (value) => value?.canEdit ?? false,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Text('Rating', style: TextStyle(fontSize: 16)),
        ),
        ListTile(
          title: Text(rating.title),
          leading: rating.icon,
          onTap: canEdit
              ? () => showRatingDialog(
                  context: context,
                  onSelected: (value) {
                    PostEditingController controller = context
                        .read<PostEditingController>();
                    controller.value = controller.value!.copyWith(
                      rating: value,
                    );
                  },
                )
              : null,
        ),
        const Divider(),
      ],
    );
  }
}

Future<Rating?> showRatingDialog({
  required BuildContext context,
  ValueChanged<Rating>? onSelected,
}) async {
  return showDialog<Rating>(
    context: context,
    builder: (context) => SimpleDialog(
      title: const Text('Rating'),
      children: Rating.values
          .map(
            (rating) => ListTile(
              title: Text(rating.title),
              leading: rating.icon,
              onTap: () {
                onSelected?.call(rating);
                Navigator.of(context).pop(rating);
              },
            ),
          )
          .toList(),
    ),
  );
}
