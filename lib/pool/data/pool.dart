class Pool {
  Map raw;

  late int id;
  late String name;
  String? description;
  List<int> postIDs = [];
  late String creator;
  late String creation;
  String? updated;
  late bool active;

  Pool.fromRaw(this.raw) {
    id = raw['id'] as int;
    name = raw['name'] as String;
    description = raw['description'] as String?;
    postIDs.addAll(raw['post_ids'].cast<int>());
    creator = raw['creator_name'] as String;
    active = raw['is_active'] as bool;
    creation = raw['created_at'] as String;
    updated = raw['updated_at'] as String?;
  }

  Uri url(String host) => Uri(scheme: 'https', host: host, path: '/pools/$id');
}
