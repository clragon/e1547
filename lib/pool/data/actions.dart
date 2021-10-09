import 'package:e1547/pool/pool.dart';

extension Link on Pool {
  Uri url(String host) => Uri(scheme: 'https', host: host, path: '/pools/$id');
}
