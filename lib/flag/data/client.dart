import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:e1547/flag/flag.dart';
import 'package:e1547/shared/shared.dart';

class FlagClient {
  FlagClient({required this.dio});

  final Dio dio;

  Future<List<PostFlag>> list({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) => dio
      .get(
        '/post_flags.json',
        queryParameters: {'page': page, 'limit': limit, ...?query},
        options: forceOptions(force),
        cancelToken: cancelToken,
      )
      .then(
        (response) => pick(
          response.data,
        ).asListOrThrow((p0) => E621PostFlag.fromJson(p0.asMapOrThrow())),
      );

  Future<void> create(int postId, String flag, {int? parent}) => dio.post(
    '/post_flags.json',
    queryParameters: {
      'post_flag[post_id]': postId,
      'post_flag[reason_name]': flag,
      if (flag == 'inferior' && parent != null) 'post_flag[parent_id]': parent,
    },
  );
}
