import 'dart:convert';

String encodeBasicAuth(String username, String password) =>
    'Basic ${base64Encode(utf8.encode('$username:$password'))}';

(String username, String password)? parseBasicAuth(String? auth) {
  if (auth == null) return null;
  RegExpMatch? fullBasicMatch =
      RegExp(r'Basic (?<encoded>[A-Za-z\d/=]+)').firstMatch(auth);
  if (fullBasicMatch == null) return null;
  RegExpMatch? credentialMatch = RegExp(r'(?<username>.+):(?<password>.+)')
      .firstMatch(
          utf8.decode(base64Decode(fullBasicMatch.namedGroup('encoded')!)));
  if (credentialMatch == null) return null;
  return (
    credentialMatch.namedGroup('username')!,
    credentialMatch.namedGroup('password')!,
  );
}

/// Returns a new URL which is guaranteed to
/// - have a scheme (defaults to https)
/// - not have a trailing slash
/// - not contain a query or fragment
String normalizeHostUrl(String url) {
  Uri uri = Uri.parse(url);
  if (uri.host.isEmpty && uri.path.isNotEmpty) {
    uri = Uri.https(uri.path);
  }
  if (uri.path.endsWith('/')) {
    uri = uri.replace(path: uri.path.substring(0, uri.path.length - 1));
  }
  if (uri.scheme.isEmpty) {
    uri = uri.replace(scheme: 'https');
  }
  uri = Uri(
    scheme: uri.scheme,
    userInfo: uri.userInfo,
    host: uri.host,
    port: uri.port,
    path: uri.path,
  );
  return uri.toString();
}
