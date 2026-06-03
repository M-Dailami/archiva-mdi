/// Model kuis yang terhubung ke satu tempat bersejarah
class Quiz {
  final String id;
  final String placeId;
  final String placeName;
  final String title;
  final String difficulty; // Pemula, Menengah, Mahir
  final int questionCount;
  final int durationMinutes;
  final int xpReward;
  final List<Question> questions;
  final bool isLocked;
  final bool isCompleted;
  final double? score;

  const Quiz({
    required this.id,
    required this.placeId,
    required this.placeName,
    required this.title,
    required this.difficulty,
    this.questionCount = 5,
    this.durationMinutes = 5,
    this.xpReward = 50,
    this.questions = const [],
    this.isLocked = false,
    this.isCompleted = false,
    this.score,
  });
}

/// Model pertanyaan kuis
class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String? explanation;

  const Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });
}
