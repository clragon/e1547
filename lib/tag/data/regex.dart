RegExp poolRegex() => RegExp(r'^pool:(?<id>\d+)$');

RegExp favRegex(String username) => RegExp(r'^fav:' + username + r'$');
