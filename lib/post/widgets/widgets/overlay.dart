import 'package:e1547/app/app.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/post/post.dart';
import 'package:flutter/material.dart';

class ImageOverlay extends StatelessWidget {
  const ImageOverlay({
    required this.post,
    required this.builder,
  });

  final Post post;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    PostsController? controller = context.read<PostsController?>();

    Widget centerText(String text) {
      return Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      );
    }

    if (post.flags.deleted) {
      return centerText('Post was deleted');
    }
    if (post.file.url == null) {
      return IconMessage(
        title: const Text('Image unavailable in safe mode'),
        icon: const Icon(Icons.image_not_supported_outlined),
        action: Padding(
          padding: const EdgeInsets.all(4),
          child: TextButton(
            onPressed: () async {
              NavigatorState navigator = Navigator.of(context);
              ClientService service = context.read<ClientService>();
              if (!service.hasCustomHost) {
                await setCustomHost(context);
              }
              if (service.hasCustomHost) {
                ClientService otherService = ClientService(
                  userAgent: service.userAgent,
                  allowedHosts: service.allowedHosts,
                  host: service.customHost,
                  customHost: service.customHost,
                  cache: service.cache,
                  credentials: service.credentials,
                  cookies: service.cookies,
                );
                navigator.push(
                  MaterialPageRoute(
                    builder: (context) =>
                        ChangeNotifierProvider<ClientService>.value(
                      value: otherService,
                      child: ClientProvider(
                        child: PostLoadingPage(post.id),
                      ),
                    ),
                  ),
                );
              }
            },
            child: const Text('Open'),
          ),
        ),
      );
    }
    if ((controller?.isDenied(post) ?? false) && !post.isFavorited) {
      return centerText('Post is blacklisted');
    }

    if (post.type == PostType.unsupported) {
      return IconMessage(
        title: Text('${post.file.ext} files are not supported'),
        icon: const Icon(Icons.image_not_supported_outlined),
        action: Padding(
          padding: const EdgeInsets.all(4),
          child: TextButton(
            onPressed: () async => launch(post.file.url!),
            child: const Text('Open'),
          ),
        ),
      );
    }

    return builder(context);
  }
}
