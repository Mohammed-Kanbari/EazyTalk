class TipModel {
  final int id;
  final int wordId;
  final String tip;
  
  TipModel({
    required this.id,
    required this.wordId,
    required this.tip,
  });
  
  factory TipModel.fromJson(Map<String, dynamic> json) {
    return TipModel(
      id: json['id'] ?? 0,
      wordId: json['word_id'] ?? 0,
      tip: json['tip'] ?? '',
    );
  }
}