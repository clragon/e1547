class TextState {
  bool bold;
  bool italic;
  bool strikeout;
  bool underline;
  bool overline;
  bool header;
  bool link;
  bool dark;

  TextState({
    required this.bold,
    required this.italic,
    required this.strikeout,
    required this.underline,
    required this.overline,
    required this.header,
    required this.link,
    required this.dark,
  });

  TextState copyWith({
    bool? bold,
    bool? italic,
    bool? strikeout,
    bool? underline,
    bool? overline,
    bool? header,
    bool? link,
    bool? dark,
  }) =>
      TextState(
        bold: bold ?? this.bold,
        italic: italic ?? this.italic,
        strikeout: strikeout ?? this.strikeout,
        underline: underline ?? this.underline,
        overline: overline ?? this.overline,
        header: header ?? this.header,
        link: link ?? this.link,
        dark: dark ?? this.dark,
      );
}
