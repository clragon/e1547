import 'package:e1547/client/client.dart';
import 'package:e1547/integrations/gelbooru/post.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sub/flutter_sub.dart';

// TODO: what the fuck
class TagInjector extends StatelessWidget {
  const TagInjector({
    super.key,
    required this.post,
    required this.child,
  });

  final Post post;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SubEffect(
      effect: () {
        CancelToken cancelToken = CancelToken();
        Future(() async {
          Client client = context.read<Client>();
          PostController postController = context.read<PostController>();
          if (post.tags['unknown']?.isEmpty ?? true) return;
          PostService postService = client.posts;
          if (postService is GelbooruPostService) {
            final categories = await postService.categorizeTags(
              tags: post.tags['unknown']!,
              cancelToken: cancelToken,
            );
            postController.replacePost(
              post.copyWith(
                tags: post.tags.values.fold<Map<String, List<String>>>(
                  {},
                  (acc, e) {
                    for (final tag in e) {
                      String category = categories[tag] ?? 'invalid';
                      acc.putIfAbsent(category, () => []).add(tag);
                    }
                    return acc;
                  },
                ),
              ),
            );
          }
        });
        return cancelToken.cancel;
      },
      keys: [post],
      child: child,
    );
  }
}
