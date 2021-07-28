String singleBrackets(String wrapped) => [
      r'(?<!\[)', // prevent double brackets
      r'(?<!\\)', // prevent escaped brackets
      r'\[', // opening backet
      wrapped,
      r'\]', // closing bracket
      r'(?!\])', // prevent double brackets
    ].join();

String blockTag(String wrapped) => singleBrackets(
      [
        wrapped,
        r'(?<expanded>,expanded)?', // read expanded
        r'(=(?<value>(.|\n)*?))?', // read value
      ].join(),
    );

String stopsAtEndChar(String wrapped) => [
      wrapped,
      r'(?=([.,!:"\s]|(\? ))?)',
    ].join();

String startsWithName(String wrapped, [bool? needsName]) => [
      r'("(?<name>[^"]+?)":)',
      if (!(needsName ?? true)) r'?',
      wrapped,
    ].join();

String linkWrap(String wrapped, [bool? needsName]) =>
    startsWithName(stopsAtEndChar(wrapped), needsName);

RegExp anyBlockTag = RegExp(
  blockTag(
    [
      r'(?<closing>\/)?', // read closing
      r'(?<tag>[\w\d]+?)', // read tag
    ].join(),
  ),
  caseSensitive: false,
);

RegExp blankless = RegExp(r'(^\n+)|(\n+$)');
