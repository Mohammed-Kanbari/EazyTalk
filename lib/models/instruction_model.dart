class InstructionModel {
  final int id;
  final int wordId;
  final int stepNumber;
  final String instruction;
  
  InstructionModel({
    required this.id,
    required this.wordId,
    required this.stepNumber,
    required this.instruction,
  });
  
  factory InstructionModel.fromJson(Map<String, dynamic> json) {
    return InstructionModel(
      id: json['id'] ?? 0,
      wordId: json['word_id'] ?? 0,
      stepNumber: json['step_number'] ?? 0,
      instruction: json['instruction'] ?? '',
    );
  }
}