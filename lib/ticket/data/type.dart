enum TicketType {
  user,
  dmail,
  comment,
  forum,
  blip,
  wiki,
  pool,
  set,
  post;

  String get id => switch (this) {
    user => 'user',
    dmail => 'dmail',
    comment => 'comment',
    forum => 'forum',
    blip => 'blip',
    wiki => 'wiki',
    pool => 'pool',
    set => 'set',
    post => 'post',
  };
}
