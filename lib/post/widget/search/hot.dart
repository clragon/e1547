import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:flutter/material.dart';

class HotPage extends StatelessWidget {
  const HotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RouterDrawerEntry<HotPage>(
      child: PostProvider.builder(
        create: (context, domain) => HotPostController(domain: domain),
        child: Consumer<PostController>(
          builder: (context, controller, child) =>
              PostsControllerHistoryConnector(
                controller: controller,
                child: PostListPage(
                  appBar: const DefaultAppBar(
                    title: Text('Hot'),
                    actions: [ContextDrawerButton()],
                  ),
                  controller: controller,
                ),
              ),
        ),
      ),
    );
  }
}
