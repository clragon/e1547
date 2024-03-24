import 'package:e1547/follow/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';

enum FollowFeature {
  database,
}

abstract class FollowService with FeatureFlagging<FollowFeature> {
  Future<Follow> get({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<Follow?> getByTags({
    required String tags,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<List<Follow>> page({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<List<Follow>> all({
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  });

  Future<void> create({
    required String tags,
    required FollowType type,
    String? title,
  });

  Future<void> update({
    required int id,
    String? tags,
    String? title,
    FollowType? type,
  });

  Future<void> markSeen({required int id}) => markAllSeen(ids: [id]);

  Future<void> markAllSeen({required List<int>? ids});

  Future<void> delete({required int id});

  Future<int> count();

  Stream<FollowSync?> get syncStream =>
      throwUnsupported(FollowFeature.database);

  FollowSync? get currentSync => throwUnsupported(FollowFeature.database);

  Future<void> sync({bool? force}) => throwUnsupported(FollowFeature.database);

  Future<void> syncWith({
    required int id,
    List<Post>? post,
    Pool? pool,
    bool? seen,
  }) =>
      throwUnsupported(FollowFeature.database);
}

abstract class FollowSync {
  bool get running;
  bool get completed;
  bool get cancelled;
  Object? get error;
  Stream<double> get progress;

  Future<void> run();
  void cancel();
}

extension type FollowsQuery._(QueryMap self) implements QueryMap {
  factory FollowsQuery({
    String? tags,
    String? title,
    List<FollowType>? types,
    bool? hasUnseen,
  }) =>
      FollowsQuery._({
        'search[tags]': tags,
        'search[title]': title,
        'search[type]': types,
        'search[has_unseen]': hasUnseen,
      }.toQuery());

  static FollowsQuery? from(QueryMap? map) {
    if (map == null) return null;
    return FollowsQuery._(map);
  }

  String? get tags => self['search[tags]'];
  String? get title => self['search[title]'];
  List<FollowType>? get type => self['search[type]']
      ?.split(',')
      .map((e) => FollowType.values.asNameMap()[e])
      .whereType<FollowType>()
      .toList();
  // TODO: implement this in Disk
  bool? get hasUnseen =>
      bool.tryParse(self['search[has_unseen]'] ?? '', caseSensitive: false);
}
