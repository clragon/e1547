import 'dart:convert';

class Credentials {
  Credentials({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;

  factory Credentials.fromJson(String str) =>
      Credentials.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Credentials.fromMap(Map<String, dynamic> json) => Credentials(
        username: json["username"],
        password: json["apikey"],
      );

  Map<String, dynamic> toMap() => {
        "username": username,
        "apikey": password,
      };

  String toAuth() {
    String auth = base64Encode(utf8.encode('$username:$password'));
    return 'Basic $auth';
  }
}
