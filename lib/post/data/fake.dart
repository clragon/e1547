import 'package:e1547/post/post.dart';
import 'package:e1547/shared/shared.dart';
import 'package:e1547/vote/data/info.dart';

// ignore: avoid_implementing_value_types
class FakePost implements Post, Fake {
  FakePost();

  @override
  final int id = Fake.id;
  @override
  final String? file = Fake.url;
  @override
  final String? sample = Fake.url;
  @override
  final String? preview = Fake.url;
  @override
  final int width = Fake.number;
  @override
  final int height = Fake.number;
  @override
  final String ext = Fake.chars(3, 'E');
  @override
  final int size = Fake.number;
  @override
  final Map<String, String?>? variants = null;
  @override
  final Map<String, List<String>> tags = {
    'general': List.generate(10, (_) => Fake.word),
    'species': List.generate(2, (_) => Fake.word),
    'character': [Fake.word],
    'artist': [Fake.word],
  };
  @override
  final int uploaderId = Fake.id;
  @override
  final DateTime createdAt = Fake.date;
  @override
  final DateTime? updatedAt = Fake.flip(Fake.date);
  @override
  final VoteInfo vote = VoteInfo(score: Fake.number);
  @override
  final bool isDeleted = false;
  @override
  final Rating rating = Rating.s;
  @override
  final int favCount = Fake.number;
  @override
  final bool isFavorited = false;
  @override
  final int commentCount = Fake.number;
  @override
  final String description = Fake.text(20);
  @override
  final List<String> sources = List.generate(2, (_) => Fake.url);
  @override
  final List<int>? pools = Fake.flip([Fake.id]);
  @override
  final Relationships relationships = Relationships(
    parentId: Fake.flip(Fake.id),
    hasChildren: false,
    hasActiveChildren: false,
    children: const [],
  );

  @override
  $PostCopyWith<Post> get copyWith => throw UnimplementedError();

  @override
  Map<String, dynamic> toJson() => throw UnimplementedError();
}
