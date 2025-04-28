import 'package:e1547/post/post.dart';

extension PostLinkExtension on Post {
  String get link => '/posts/$id';
}
