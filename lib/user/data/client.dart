import 'package:e1547/interface/interface.dart';
import 'package:e1547/user/user.dart';

enum UserFeature {
  report,
}

abstract class UsersClient with FeatureFlagging<UserFeature> {
  // Technically missing users()
  Future<User> get({
    required String id,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<void> report({
    required int id,
    required String reason,
  }) =>
      throwUnsupported(UserFeature.report);
}

// ignore: one_member_abstracts
abstract class AccountsClient {
  Future<Account?> get({
    bool? force,
    CancelToken? cancelToken,
  });
}
