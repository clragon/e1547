class Comment {
  Map raw;

  int id;
  int creatorID;
  String creator;
  String body;
  int score;
  String creation;
  String update;

  Comment.fromRaw(this.raw) {
    id = raw['id'] as int;
    creatorID = raw['creator_id'] as int;
    creator = raw['creator_name'] as String;
    body = raw['body'] as String;
    score = raw['score'] as int;
    creation = raw['created_at'] as String;
    update = raw['updated_at'] as String;
  }
}
