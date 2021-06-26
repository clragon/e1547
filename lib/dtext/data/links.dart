enum LinkWord {
  post,
  forum,
  topic,
  comment,
  blip,
  pool,
  set,
  takedown,
  record,
  ticket,
  category,
  thumb,
}

String linkToDisplay(String link) {
  String display = link;
  display = display.replaceFirst('https://', '');
  display = display.replaceFirst('http://', '');
  display = display.replaceFirst('www.', '');
  display = display.replaceAll(RegExp(r'\?(.*)'), '');
  display = display.replaceAll(RegExp(r'\/$'), '');
  return display;
}
