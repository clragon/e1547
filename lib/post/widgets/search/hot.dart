import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class HotPage extends StatelessWidget {
  const HotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RouterDrawerEntry<HotPage>(
      child: PostProvider.builder(
        create: (context, client) => HotPostController(client: client),
        child: Consumer<PostController>(
          builder: (context, controller, child) =>
              PostsControllerHistoryConnector(
            controller: controller,
            child: PostsPage(
              appBar: const ContextSizedAppBar(
                title: Text('Hot'),
              ),
              controller: controller,
            ),
          ),
        ),
      ),
    );
  }
}
