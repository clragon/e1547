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
