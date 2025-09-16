import 'package:drift/drift.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/shared/shared.dart';

class FollowClient {
  FollowClient({required GeneratedDatabase database, required this.identity})
    : repository = FollowRepository(database: database);

  final Identity identity;

  final FollowRepository repository;

  Future<Follow> get({
    required int id,
    bool? force,
    CancelToken? cancelToken,
  }) => repository.get(id);

  Future<Follow?> getByTags({
    required String tags,
    bool? force,
    CancelToken? cancelToken,
  }) => repository.getByTags(tags, identity.id);

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

  Future<void> create({
    required String tags,
    required FollowType type,
    String? title,
    String? alias,
  }) => repository.add(
    FollowRequest(tags: tags, type: type, title: title, alias: alias),
    identity.id,
  );

  Future<void> update({
    required int id,
    String? tags,
    String? title,
    FollowType? type,
  }) => repository.transaction(() async {
    await ((repository.update(
      repository.followsTable,
    ))..where((tbl) => tbl.id.equals(id))).write(
      FollowCompanion(
        title: title != null
            ? Value(title.nullWhenEmpty)
            : const Value.absent(),
        type: type != null ? Value(type) : const Value.absent(),
      ),
    );
    if (tags?.nullWhenEmpty != null) {
      await ((repository.update(
        repository.followsTable,
      ))..where((tbl) => tbl.id.equals(id))).write(
        FollowCompanion(
          tags: Value(tags!),
          updated: const Value(null),
          unseen: const Value(null),
          thumbnail: const Value(null),
          latest: const Value(null),
        ),
      );
    }
  });

  Future<void> markSeen(int id) => markAllSeen([id]);

  Future<void> markAllSeen(List<int>? ids) =>
      repository.markAllSeen(ids: ids, identity: identity.id);

  Future<void> delete(int id) => repository.remove(id);

  Future<int> count() => repository.length(identity: identity.id);
}

extension type FollowsQuery._(QueryMap self) implements QueryMap {
  factory FollowsQuery({
    String? tags,
    String? title,
    List<FollowType>? types,
    bool? hasUnseen,
  }) => FollowsQuery._(
    {
      'search[tags]': tags,
      'search[title]': title,
      'search[type]': types,
      'search[has_unseen]': hasUnseen,
    }.toQuery(),
  );

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
