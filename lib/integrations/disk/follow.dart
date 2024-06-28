import 'dart:async';

import 'package:drift/drift.dart';
import 'package:e1547/follow/data/database.drift.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/pool/pool.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:rxdart/rxdart.dart';

abstract class DiskFollowService extends FollowService with Disposable {
  DiskFollowService({
    required GeneratedDatabase database,
    required this.identity,
  }) : repository = FollowRepository(database: database);

  final Identity identity;
  final FollowRepository repository;

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
      repository.getByTags(tags, identity.id);

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
      identity: identity.id,
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
      identity: identity.id,
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
        identity.id,
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
  Future<void> markAllSeen(List<int>? ids) =>
      repository.markAllSeen(ids: ids, identity: identity.id);

  @override
  Future<void> delete(int id) => repository.remove(id);

  @override
  Future<int> count() => repository.length(identity: identity.id);

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
    final sync = createSync(force: force);
    _currentSync = sync;
    _syncStream.add(sync);
    await sync.run();
    _currentSync = null;
    _syncStream.add(null);
  }

  FollowSync createSync({bool? force});

  @override
  Future<void> syncWith({
    required int id,
    List<Post>? posts,
    Pool? pool,
    bool? seen,
  }) =>
      ((repository.update(repository.followsTable))
            ..where((tbl) => tbl.id.equals(id)))
          .write(
        FollowCompanion(
          latest: posts?.isNotEmpty ?? false
              ? Value(posts!.first.id)
              : const Value.absent(),
          thumbnail: posts?.isNotEmpty ?? false
              ? Value(posts!.first.sample)
              : const Value.absent(),
          title: pool?.name != null
              ? Value(tagToName(pool!.name))
              : const Value.absent(),
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
