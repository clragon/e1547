import 'package:e1547/topic/topic.dart';

extension Link on Topic {
  Uri url(String host) =>
      Uri(scheme: 'https', host: host, path: '/forum_topics/$id');
}
