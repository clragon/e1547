class Reply {
  Map raw;

  int id;
  int topicId;
  int creatorId;
  String body;
  String creation;
  String update;

  Reply.fromRaw(this.raw) {
    id = raw['id'] as int;
    topicId = raw['topic_id'] as int;
    creatorId = raw['creator_id'] as int;
    body = raw['body'] as String;
    creation = raw['created_at'] as String;
    update = raw['updated_at'] as String;
  }
}
