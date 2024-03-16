import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:e1547/client/client.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/integrations/disk/follow.dart';
import 'package:e1547/interface/interface.dart';
import 'package:e1547/logs/logs.dart';
import 'package:e1547/pool/data/client.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/tag/tag.dart';
import 'package:e1547/traits/traits.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

class E621FollowsClient extends DiskFollowsClient {
  E621FollowsClient({
    required super.database,
    required super.identity,
    required this.traits,
    required this.postsClient,
    this.poolsClient,
    this.tagsClient,
  });

  final ValueNotifier<Traits> traits;
  final PostsClient postsClient;
  final PoolsClient? poolsClient;
  final TagsClient? tagsClient;

  @override
  FollowSync createSync({bool? force}) => E621FollowSync(
        dao: dao,
        traits: traits,
        postsClient: postsClient,
        poolsClient: poolsClient,
        tagsClient: tagsClient,
        force: force,
      );
}

class E621FollowSync implements FollowSync {
  E621FollowSync({
    required this.dao,
    required this.traits,
    required this.postsClient,
    this.poolsClient,
    this.tagsClient,
    this.force,
  });

  late final Logger logger = Logger('$runtimeType#$hashCode');

  final int refreshAmount = 5;
  final Duration refreshRate = const Duration(hours: 1);

  final FollowsDao dao;
  final ValueNotifier<Traits> traits;
  final PostsClient postsClient;
  final PoolsClient? poolsClient;
  final TagsClient? tagsClient;
  final bool? force;

  CancelableOperation<void>? _operation;

  @override
  bool get running => _operation != null;

  @override
  bool get completed => _operation?.isCompleted ?? false;

  @override
  bool get cancelled => _operation?.isCanceled ?? false;

  @override
  void cancel() {
    logger.fine('Sync cancelled!');
    _operation?.cancel();
  }

  @override
  Object? get error => _error;
  Object? _error;

  @override
  Stream<double> get progress =>
      _remaining.stream.map((e) => _total == null ? 0 : e / _total!);

  late final StreamController<int> _remaining = BehaviorSubject()
    ..stream.listen(
      (value) => logger.fine('Syncing ${(_total ?? 0) - value} follows...'),
      onError: (exception, stacktrace) {
        _error = exception;
        if (exception is Error) {
          logger.shout('Sync failed!', exception, stacktrace);
        } else {
          logger.warning('Sync failed!', exception, stacktrace);
        }
      },
      onDone: () => logger.info('Sync finished!'),
    );

  int? _total;

  List<String> _previousTags = [];

  void _assertNoDuplicates(List<String> tags) {
    bool tagsAreDifferent =
        !const DeepCollectionEquality().equals(_previousTags, tags);
    assert(
      tagsAreDifferent,
      'Sync tried refreshing same follows twice!',
    );
    _previousTags = tags;
  }

  @override
  Future<void> run() async {
    _operation ??= CancelableOperation.fromFuture(_run());
    return _operation!.value;
  }

  Future<void> _run() async {
    logger.info('Sync started!');
    try {
      if (force ?? false) {
        logger.fine('Force refreshing follows...');
        await dao.transaction(() async {
          List<Follow> follows = await dao.all(
            types: [FollowType.notify, FollowType.update],
          );
          for (final follow in follows) {
            await dao.replace(follow.copyWith(
              updated: null,
            ));
          }
        });
      }

      while (!cancelled) {
        List<Follow> follows = [];

        follows.addAll(await dao.outdated(
          minAge: refreshRate,
          types: [FollowType.notify, FollowType.update],
        ));

        follows.addAll(await dao.fresh(
          types: [FollowType.bookmark],
        ));

        _total ??= follows.length;
        _remaining.add(_total! - follows.length);

        List<Follow> singles = follows.where((e) => e.isSingle).toList();
        if (singles.isNotEmpty) {
          List<Follow> updates = await _refreshSingles(singles);
          await dao.transaction(() async {
            for (final update in updates) {
              await dao.replace(update);
            }
          });
          continue;
        }

        List<Follow> multiples = follows.whereNot(singles.contains).toList();
        if (multiples.isNotEmpty) {
          Follow update = await _refreshMultiples(multiples);
          await dao.replace(update);
          continue;
        }

        break;
      }
    } on Object catch (error, stacktrace) {
      _remaining.addError(error, stacktrace);
    } finally {
      _remaining.close();
    }
  }

  Future<List<Follow>> _refreshSingles(List<Follow> singles) async {
    List<Follow> follows = singles.take(40).toList();
    List<String> tags = follows.map((e) => e.tags).toList();
    _assertNoDuplicates(tags);

    int limit = follows.length * refreshAmount;
    List<Post> allPosts = await rateLimit(postsClient.byTags(
      tags: tags,
      page: 1,
      limit: limit,
      force: force,
    ));

    Map<Follow, List<Post>> assign(List<Follow> follows, List<Post> posts) {
      Map<Follow, List<Post>> result = {};
      for (final follow in follows) {
        result.putIfAbsent(follow, () => []);
        for (final post in posts) {
          if (post.hasTag(follow.alias ?? follow.tags)) {
            result.update(
              follow,
              (value) => value..add(post),
            );
          }
        }
      }
      return result;
    }

    Map<Follow, List<Post>> updates = assign(follows, allPosts);

    bool hasLeftovers() {
      List<Post> picked = updates.values.flattened.toList();
      List<Post> leftovers = allPosts.whereNot(picked.contains).toList();
      if (leftovers.isNotEmpty) {
        logger.info(
          'Sync found ${leftovers.length} leftover posts!\n'
          '${prettyLogObject(leftovers, header: 'Leftovers')}',
        );
      }
      return leftovers.isNotEmpty;
    }

    if (hasLeftovers() && tagsClient != null) {
      for (final update in Map.from(updates).entries) {
        Follow follow = update.key;
        List<Post> posts = update.value;
        if (posts.isNotEmpty) continue;
        String? alias = await rateLimit(tagsClient!.aliases(
          query: {'search[antecedent_name]': follow.tags},
        ));
        if (alias != follow.alias) {
          Follow updated = follow.copyWith(alias: alias);
          updates[updated] = updates.remove(follow)!;
          logger.info(
            'Sync corrected alias for ${follow.tags} to $alias',
          );
          updates = assign(updates.keys.toList(), allPosts);
          if (!hasLeftovers()) break;
        }
      }
    }

    List<Follow> result = [];
    for (final update in updates.entries) {
      Follow follow = update.key;
      List<Post> posts = update.value;
      bool limitReached = posts.length >= 5;
      bool latestReached = posts.any((e) => e.id == follow.latest);
      bool depleted = allPosts.length < limit;
      if ([limitReached, latestReached, depleted].any((e) => e)) {
        posts.removeWhere((e) => e.isDeniedBy(traits.value.denylist));
        result.add(follow.withUnseen(posts));
      }
    }
    return result;
  }

  Future<Follow> _refreshMultiples(List<Follow> multiples) async {
    Follow follow = multiples.first;
    _assertNoDuplicates([follow.tags]);

    List<Post> posts = await rateLimit(postsClient.page(
      query: {'tags': follow.tags},
      limit: refreshAmount,
      ordered: false,
      force: force,
    ));
    posts.removeWhere((e) => e.isDeniedBy(traits.value.denylist));
    follow = follow.withUnseen(posts);
    if (poolsClient != null) {
      RegExpMatch? match = poolRegex().firstMatch(follow.tags);
      if (follow.title == null && match != null) {
        try {
          follow = follow.withPool(
            await poolsClient!.get(
              id: int.parse(match.namedGroup('id')!),
              force: force,
            ),
          );
        } on ClientException catch (e) {
          if (e.response?.statusCode == HttpStatus.notFound) {
            follow = follow.copyWith(
              type: FollowType.bookmark,
            );
            logger.info(
              'Sync found no pool for ${follow.tags}. Set to bookmarked!',
            );
          } else {
            rethrow;
          }
        }
      }
    }
    return follow;
  }
}
