import 'package:e1547/dtext/dtext.dart';

final DTextParser codeParser = DTextParser(
  regex: RegExp(r'`(?<code>(.|\n)*?)`'),
  tranformer: (context, match, state) => plainText(
    context: context,
    text: ' ${match.namedGroup('code')!} ',
    state: state.copyWith(
      highlight: true,
    ),
  ),
);
