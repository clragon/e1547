class Thread {
  Map raw;

  int id;
  int creatorID;
  String title;
  int posts;
  bool sticky;
  bool locked;
  String creation;
  String updated;

  Thread.fromRaw(this.raw) {
    id = raw['id'] as int;
    title = raw['title'] as String;
    creatorID = raw['creator_id'] as int;
    creation = raw['created_at'] as String;
    updated = raw['updated_at'] as String;
    posts = raw['response_count'] as int;
    sticky = raw['is_sticky'] as bool;
    locked = raw['is_locked'] as bool;
  }
}
