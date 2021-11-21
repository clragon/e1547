import 'package:e1547/user/user.dart';

extension Linking on User {
  Uri url(String host) => Uri(scheme: 'https', host: host, path: '/users/$id');
}
