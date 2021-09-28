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
  Uri url = Uri.parse(link);
  List<String> allowed = ['v'];
  Map<String, dynamic> parameters = Map.of(url.queryParameters);
  parameters.removeWhere((key, value) => !allowed.contains(key));
  url = url.replace(
    scheme: '',
    queryParameters: parameters.length > 0 ? parameters : null,
    fragment: null,
  );
  String display = url.toString();
  display = display.replaceAll(RegExp(r'^//'), '');
  display = display.replaceFirst(RegExp(r'^www.'), '');
  return display;
}
