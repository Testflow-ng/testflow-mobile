class Subject {
  final String id;
  final String code;
  final String title;
  final String? description;
  final String? level;
  final int questionCount;

  const Subject({
    required this.id,
    required this.code,
    required this.title,
    this.description,
    this.level,
    required this.questionCount,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String,
      code: json['code'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      level: json['level'] as String?,
      questionCount: (json['questionCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class LeaderboardEntry {
  final String? username;
  final String fullName;
  final int score;
  final int totalQuestions;
  final int timeTaken;

  const LeaderboardEntry({
    this.username,
    required this.fullName,
    required this.score,
    required this.totalQuestions,
    required this.timeTaken,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      username: json['username'] as String?,
      fullName: json['fullName'] as String? ?? 'Student',
      score: (json['score'] as num?)?.toInt() ?? 0,
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
      timeTaken: (json['timeTaken'] as num?)?.toInt() ?? 0,
    );
  }
}
