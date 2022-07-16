import 'package:e1547/user/user.dart';

extension Linking on User {
  String get link => '/users/$id';
}
