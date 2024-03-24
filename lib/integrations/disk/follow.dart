import 'dart:async';

import 'package:drift/drift.dart';
import 'package:e1547/follow/data/database.drift.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:rxdart/rxdart.dart';

abstract class DiskFollowsClient extends FollowsClient with Disposable {
  DiskFollowsClient({
    required this.database,
    required this.identity,
  }) : repository =
            FollowsRepository(database: database, identity: identity.id);

  final GeneratedDatabase database;
  final Identity identity;
  final FollowsRepository repository;

  @override
  Set<FollowFeature> get features => {
        FollowFeature.database,
      };

  @override
  Future<Follow> get({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  }) =>
      repository.get(id);

  @override
  Future<Follow?> getByTags({
    required String tags,
    bool? force,
    CancelToken? cancelToken,
  }) =>
      (repository.select(repository.followsTable)
            ..where((tbl) => tbl.tags.equals(tags)))
          .watchSingleOrNull()
          .future;

  @override
  Future<List<Follow>> page({
    int? page,
    int? limit,
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) {
    final search = FollowsQuery.from(query);
    return repository.page(
      page: page ?? 1,
      limit: limit,
      tagRegex: search?.tags?.infixRegex,
      titleRegex: search?.title?.infixRegex,
      hasUnseen: search?.hasUnseen,
      types: search?.type,
    );
  }

  @override
  Future<List<Follow>> all({
    QueryMap? query,
    bool? force,
    CancelToken? cancelToken,
  }) {
    final search = FollowsQuery.from(query);
    return repository.all(
      tagRegex: search?.tags?.infixRegex,
      titleRegex: search?.title?.infixRegex,
      types: search?.type,
      hasUnseen: search?.hasUnseen,
    );
  }

  @override
  Future<void> create({
    required String tags,
    required FollowType type,
    String? title,
    String? alias,
  }) =>
      repository.add(
        FollowRequest(
          tags: tags,
          type: type,
          title: title,
          alias: alias,
        ),
      );

  @override
  Future<void> update({
    required int id,
    String? tags,
    String? title,
    FollowType? type,
  }) =>
      repository.transaction(() async {
        await ((repository.update(repository.followsTable))
              ..where((tbl) => tbl.id.equals(id)))
            .write(FollowCompanion(
          title:
              title != null ? Value(title.nullWhenEmpty) : const Value.absent(),
          type: type != null ? Value(type) : const Value.absent(),
        ));
        if (tags?.nullWhenEmpty != null) {
          await ((repository.update(repository.followsTable))
                ..where((tbl) => tbl.id.equals(id)))
              .write(FollowCompanion(
            tags: Value(tags!),
            updated: const Value(null),
            unseen: const Value(null),
            thumbnail: const Value(null),
            latest: const Value(null),
          ));
        }
      });

  @override
  Future<void> markAllSeen({required List<int>? ids}) =>
      ((repository.update(repository.followsTable))
            ..where((tbl) => Variable(ids).isNull() | tbl.id.isIn(ids!)))
          .write(const FollowCompanion(unseen: Value(0)));

  @override
  Future<void> delete({required int id}) => repository.remove(id);

  @override
  Future<int> count() => repository.length();

  @override
  Stream<FollowSync?> get syncStream => _syncStream.stream;
  final StreamController<FollowSync?> _syncStream =
      BehaviorSubject<FollowSync?>();

  @override
  FollowSync? get currentSync => _currentSync;
  FollowSync? _currentSync;

  @override
  Future<void> sync({bool? force}) async {
    if (_currentSync != null) return;
    _currentSync = createSync(force: force);
    _syncStream.add(_currentSync);
    await _currentSync!.run();
    _currentSync = null;
    _syncStream.add(_currentSync);
  }

  FollowSync createSync({bool? force});

  @override
  Future<void> syncWith({
    required int id,
    List<Post>? post,
    Pool? pool,
    bool? seen,
  }) =>
      ((repository.update(repository.followsTable))
            ..where((tbl) => tbl.id.equals(id)))
          .write(
        FollowCompanion(
          latest: post?.isNotEmpty ?? false
              ? Value(post!.first.id)
              : const Value.absent(),
          thumbnail: post?.isNotEmpty ?? false
              ? Value(post!.first.sample)
              : const Value.absent(),
          title: pool?.name != null ? Value(pool!.name) : const Value.absent(),
          unseen: seen ?? true ? const Value(0) : const Value.absent(),
        ),
      );

  @override
  void dispose() {
    _currentSync?.cancel();
    _currentSync = null;
    _syncStream.add(_currentSync);
    _syncStream.close();
    super.dispose();
  }
}
