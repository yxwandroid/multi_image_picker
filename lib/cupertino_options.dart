class CupertinoOptions {
  final String backgroundColor;
  final String selectionShadowColor;
  final String selectionStrokeColor;
  final String selectionFillColor;
  final String selectionTextColor;
  final String selectionCharacter;

  const CupertinoOptions({
    this.backgroundColor,
    this.selectionFillColor,
    this.selectionShadowColor,
    this.selectionStrokeColor,
    this.selectionTextColor,
    this.selectionCharacter,
  });

  Map<String, String> toJson() {
    return {
      "backgroundColor": backgroundColor ?? "",
      "selectionFillColor": selectionFillColor ?? "",
      "selectionShadowColor": selectionShadowColor ?? "",
      "selectionStrokeColor": selectionStrokeColor ?? "",
      "selectionTextColor": selectionTextColor ?? "",
      "selectionCharacter": selectionCharacter ?? "",
    };
  }
}
