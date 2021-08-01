import 'package:e1547/pool.dart';

extension link on Pool {
  Uri url(String host) => Uri(scheme: 'https', host: host, path: '/pools/$id');
}
