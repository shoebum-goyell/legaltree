class Statement {
  String inputText;
  String outputText;

  Statement(this.inputText, this.outputText);

  Map<String, dynamic> toJson() => {
    'inputText': inputText,
    'outputText': outputText,
  };

  factory Statement.fromJson(Map<String, dynamic> json) {
    return Statement(
      json['inputText'] as String,
      json['outputText'] as String,
    );
  }
}