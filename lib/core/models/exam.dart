class ExamQuestion {
  final int index;
  final String stem;
  final List<String> options;
  final int? selectedOption;
  final bool markedForReview;

  const ExamQuestion({
    required this.index,
    required this.stem,
    required this.options,
    this.selectedOption,
    required this.markedForReview,
  });

  factory ExamQuestion.fromJson(Map<String, dynamic> json) {
    return ExamQuestion(
      index: (json['index'] as num).toInt(),
      stem: json['stem'] as String,
      options:
          (json['options'] as List<dynamic>).map((e) => e.toString()).toList(),
      selectedOption: (json['selectedOption'] as num?)?.toInt(),
      markedForReview: json['markedForReview'] as bool? ?? false,
    );
  }

  ExamQuestion copyWith({
    Object? selectedOption = _sentinel,
    bool? markedForReview,
  }) {
    return ExamQuestion(
      index: index,
      stem: stem,
      options: options,
      selectedOption: selectedOption == _sentinel
          ? this.selectedOption
          : selectedOption as int?,
      markedForReview: markedForReview ?? this.markedForReview,
    );
  }

  static const _sentinel = Object();
}

class ExamSession {
  final String id;
  final String subjectCode;
  final String status;
  final int durationMinutes;
  final int remainingSeconds;
  final int totalQuestions;
  final List<ExamQuestion> questions;

  const ExamSession({
    required this.id,
    required this.subjectCode,
    required this.status,
    required this.durationMinutes,
    required this.remainingSeconds,
    required this.totalQuestions,
    required this.questions,
  });

  factory ExamSession.fromJson(Map<String, dynamic> json) {
    return ExamSession(
      id: json['id'] as String,
      subjectCode: json['subjectCode'] as String,
      status: json['status'] as String,
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      remainingSeconds: (json['remainingSeconds'] as num?)?.toInt() ?? 0,
      totalQuestions: (json['totalQuestions'] as num).toInt(),
      questions: (json['questions'] as List<dynamic>)
          .map((q) => ExamQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get isInProgress => status == 'in_progress';
}

class ResultQuestion {
  final int index;
  final String stem;
  final List<String> options;
  final int? selectedOption;
  final int correctOption;
  final String? explanation;
  final bool isCorrect;

  const ResultQuestion({
    required this.index,
    required this.stem,
    required this.options,
    this.selectedOption,
    required this.correctOption,
    this.explanation,
    required this.isCorrect,
  });

  factory ResultQuestion.fromJson(Map<String, dynamic> json) {
    return ResultQuestion(
      index: (json['index'] as num).toInt(),
      stem: json['stem'] as String,
      options:
          (json['options'] as List<dynamic>).map((e) => e.toString()).toList(),
      selectedOption: (json['selectedOption'] as num?)?.toInt(),
      correctOption: (json['correctOption'] as num).toInt(),
      explanation: json['explanation'] as String?,
      isCorrect: json['isCorrect'] as bool? ?? false,
    );
  }

  bool get wasAnswered => selectedOption != null;
}

class ExamResult {
  final String id;
  final String subjectCode;
  final int score;
  final int correctCount;
  final int totalQuestions;
  final int durationMinutes;
  final DateTime? submittedAt;
  final List<ResultQuestion> questions;

  const ExamResult({
    required this.id,
    required this.subjectCode,
    required this.score,
    required this.correctCount,
    required this.totalQuestions,
    required this.durationMinutes,
    this.submittedAt,
    required this.questions,
  });

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      id: json['id'] as String,
      subjectCode: json['subjectCode'] as String,
      score: (json['score'] as num?)?.toInt() ?? 0,
      correctCount: (json['correctCount'] as num?)?.toInt() ?? 0,
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      submittedAt: json['submittedAt'] != null
          ? DateTime.tryParse(json['submittedAt'] as String)
          : null,
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((q) => ResultQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SessionSummary {
  final String id;
  final String subjectCode;
  final String status;
  final int? score;
  final int? correctCount;
  final int totalQuestions;
  final DateTime? startedAt;
  final DateTime? submittedAt;

  const SessionSummary({
    required this.id,
    required this.subjectCode,
    required this.status,
    this.score,
    this.correctCount,
    required this.totalQuestions,
    this.startedAt,
    this.submittedAt,
  });

  factory SessionSummary.fromJson(Map<String, dynamic> json) {
    return SessionSummary(
      id: json['id'] as String,
      subjectCode: json['subjectCode'] as String,
      status: json['status'] as String,
      score: (json['score'] as num?)?.toInt(),
      correctCount: (json['correctCount'] as num?)?.toInt(),
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'] as String)
          : null,
      submittedAt: json['submittedAt'] != null
          ? DateTime.tryParse(json['submittedAt'] as String)
          : null,
    );
  }

  bool get isInProgress => status == 'in_progress';
}

class SubjectStats {
  final String subjectCode;
  final int attempts;
  final int averageScore;
  final int bestScore;

  const SubjectStats({
    required this.subjectCode,
    required this.attempts,
    required this.averageScore,
    required this.bestScore,
  });

  factory SubjectStats.fromJson(Map<String, dynamic> json) {
    return SubjectStats(
      subjectCode: json['subjectCode'] as String,
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      averageScore: (json['averageScore'] as num?)?.toInt() ?? 0,
      bestScore: (json['bestScore'] as num?)?.toInt() ?? 0,
    );
  }
}

class StudentStats {
  final int totalExams;
  final int averageScore;
  final int bestScore;
  final int totalCorrect;
  final int totalAnswered;
  final List<SubjectStats> perSubject;

  const StudentStats({
    required this.totalExams,
    required this.averageScore,
    required this.bestScore,
    required this.totalCorrect,
    required this.totalAnswered,
    required this.perSubject,
  });

  factory StudentStats.fromJson(Map<String, dynamic> json) {
    return StudentStats(
      totalExams: (json['totalExams'] as num?)?.toInt() ?? 0,
      averageScore: (json['averageScore'] as num?)?.toInt() ?? 0,
      bestScore: (json['bestScore'] as num?)?.toInt() ?? 0,
      totalCorrect: (json['totalCorrect'] as num?)?.toInt() ?? 0,
      totalAnswered: (json['totalAnswered'] as num?)?.toInt() ?? 0,
      perSubject: (json['perSubject'] as List<dynamic>? ?? [])
          .map((s) => SubjectStats.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  static const empty = StudentStats(
    totalExams: 0,
    averageScore: 0,
    bestScore: 0,
    totalCorrect: 0,
    totalAnswered: 0,
    perSubject: [],
  );
}
