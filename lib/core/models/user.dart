class User {
  final String id;
  final String fullName;
  final String? username;
  final String email;
  final String? matricNumber;
  final String role;
  final String? level;
  final String? department;
  final int streakCount;
  final List<String> pinnedSubjects;
  final bool showOnLeaderboard;
  final bool isEmailVerified;

  const User({
    required this.id,
    required this.fullName,
    this.username,
    required this.email,
    this.matricNumber,
    required this.role,
    this.level,
    this.department,
    required this.streakCount,
    required this.pinnedSubjects,
    required this.showOnLeaderboard,
    required this.isEmailVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      fullName: json['fullName'] as String? ?? '',
      username: json['username'] as String?,
      email: json['email'] as String? ?? '',
      matricNumber: json['matricNumber'] as String?,
      role: json['role'] as String? ?? 'student',
      level: json['level'] as String?,
      department: json['department'] as String?,
      streakCount: (json['streakCount'] as num?)?.toInt() ?? 0,
      pinnedSubjects: (json['pinnedSubjects'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      showOnLeaderboard: json['showOnLeaderboard'] as bool? ?? true,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
    );
  }

  String get firstName => fullName.trim().split(RegExp(r'\s+')).first;
}
