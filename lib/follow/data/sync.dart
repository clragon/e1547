import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:e1547/domain/domain.dart';
import 'package:e1547/follow/follow.dart';
import 'package:e1547/identity/identity.dart';
import 'package:e1547/logs/logs.dart';
import 'package:e1547/pool/data/client.dart';
import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/tag/tag.dart';
import 'package:rxdart/rxdart.dart';

class FollowSync {
  FollowSync({
    required this.client,
    required this.persona,
    required this.postsClient,
    this.poolsClient,
    this.tagsClient,
    this.force,
  });

  late final Logger logger = Logger('$runtimeType#$hashCode');

  final int refreshAmount = 5;
  final Duration refreshRate = const Duration(hours: 1);

  final FollowClient client;
  final Persona persona;
  final PostClient postsClient;
  final PoolClient? poolsClient;
  final TagClient? tagsClient;
  final bool? force;

  CancelableOperation<void>? _operation;

  bool get running => _operation != null;

  bool get completed => _operation?.isCompleted ?? false;

  bool get cancelled => _operation?.isCanceled ?? false;

  void cancel() {
    logger.fine('Sync cancelled!');
    _operation?.cancel();
  }

  Object? get error => _error;
  Object? _error;

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
    bool tagsAreDifferent = !const DeepCollectionEquality().equals(
      _previousTags,
      tags,
    );
    assert(tagsAreDifferent, 'Sync tried refreshing same follows twice!');
    _previousTags = tags;
  }

  Future<void> run() async {
    _operation ??= CancelableOperation.fromFuture(_run());
    return _operation!.value;
  }

  Future<void> _run() async {
    logger.info(
      'Sync started for '
      '${persona.identity.usernameOrAnon} on ${persona.identity.host}',
    );
    try {
      if (force ?? false) {
        logger.fine('Force refreshing follows...');
        await client.transaction(() async {
          List<Follow> follows = await client.all(
            query:
                (FollowParams()..types = {FollowType.notify, FollowType.update})
                    .query,
          );
          for (final follow in follows) {
            await client.replace(follow.copyWith(updated: null));
          }
        });
      }

      while (!cancelled) {
        List<Follow> follows = [];

        follows.addAll(
          await client.outdated(
            minAge: refreshRate,
            types: [FollowType.notify, FollowType.update],
            identity: persona.identity.id,
          ),
        );

        follows.addAll(
          await client.fresh(
            types: [FollowType.bookmark],
            identity: persona.identity.id,
          ),
        );

        _total ??= follows.length;
        _remaining.add(_total! - follows.length);

        List<Follow> singles = follows.where((e) => e.isSingle).toList();
        if (singles.isNotEmpty) {
          List<Follow> updates = await _refreshSingles(singles);
          await client.transaction(() async {
            for (final update in updates) {
              await client.replace(update);
            }
          });
          continue;
        }

        List<Follow> multiples = follows.whereNot(singles.contains).toList();
        if (multiples.isNotEmpty) {
          Follow update = await _refreshMultiples(multiples);
          await client.replace(update);
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
    List<Post> allPosts = await rateLimit(
      postsClient.byTags(tags: tags, page: 1, limit: limit, force: force),
    );

    Map<Follow, List<Post>> assign(List<Follow> follows, List<Post> posts) {
      Map<Follow, List<Post>> result = {};
      for (final follow in follows) {
        result.putIfAbsent(follow, () => []);
        for (final post in posts) {
          if (post.hasTag(follow.alias ?? follow.tags)) {
            result.update(follow, (value) => value..add(post));
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
        String? alias = await rateLimit(
          tagsClient!.aliases(query: {'search[antecedent_name]': follow.tags}),
        );
        if (alias != follow.alias) {
          Follow updated = follow.copyWith(alias: alias);
          updates[updated] = updates.remove(follow)!;
          await client.replace(updated);
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
        posts.removeWhere((e) => e.isDeniedBy(persona.traits.value.denylist));
        result.add(follow.withUnseen(posts));
      }
    }
    return result;
  }

  Future<Follow> _refreshMultiples(List<Follow> multiples) async {
    Follow follow = multiples.first;
    _assertNoDuplicates([follow.tags]);

    List<Post> posts = await rateLimit(
      postsClient.page(
        query: {'tags': follow.tags},
        limit: refreshAmount,
        ordered: false,
        force: force,
      ),
    );
    posts.removeWhere((e) => e.isDeniedBy(persona.traits.value.denylist));
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
            follow = follow.copyWith(type: FollowType.bookmark);
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
