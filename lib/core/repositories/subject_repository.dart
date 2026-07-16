import '../api/api_client.dart';
import '../models/subject.dart';

class SubjectRepository {
  final ApiClient _client;

  const SubjectRepository(this._client);

  Future<List<Subject>> list() async {
    final data = await _client.get('/api/subjects');
    return (data['subjects'] as List<dynamic>)
        .map((s) => Subject.fromJson(s as Map<String, dynamic>))
        .toList();
  }

  Future<List<LeaderboardEntry>> leaderboard(String subjectId) async {
    final data = await _client.get('/api/subjects/$subjectId/leaderboard');
    return (data['leaderboard'] as List<dynamic>)
        .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<String>> togglePin(String subjectId) async {
    final data = await _client.post('/api/subjects/$subjectId/pin');
    return (data['pinnedSubjects'] as List<dynamic>)
        .map((e) => e.toString())
        .toList();
  }
}
