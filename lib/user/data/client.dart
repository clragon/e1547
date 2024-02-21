import 'package:e1547/interface/interface.dart';
import 'package:e1547/user/user.dart';

enum UsersFeature {
  report,
}

abstract class UsersClient with FeatureFlagging<UsersFeature> {
  // Technically missing users()
  Future<User> user({
    required String id,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<void> reportUser({
    required int id,
    required String reason,
  }) =>
      throwUnsupported(UsersFeature.report);
}

// ignore: one_member_abstracts
abstract class AccountsClient {
  Future<Account?> account({
    bool? force,
    CancelToken? cancelToken,
  });
}
