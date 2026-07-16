import '../api/api_client.dart';
import '../models/exam.dart';

class ExamRepository {
  final ApiClient _client;

  const ExamRepository(this._client);

  Future<ExamSession> start({
    required String subject,
    int? questionCount,
    int? durationMinutes,
  }) async {
    final data = await _client.post('/api/exam-sessions', body: {
      'subject': subject,
      if (questionCount != null) 'questionCount': questionCount,
      if (durationMinutes != null) 'durationMinutes': durationMinutes,
    });
    return ExamSession.fromJson(data['session'] as Map<String, dynamic>);
  }

  Future<ExamSession> getSession(String id) async {
    final data = await _client.get('/api/exam-sessions/$id');
    return ExamSession.fromJson(data['session'] as Map<String, dynamic>);
  }

  Future<void> saveAnswer(
    String id, {
    required int questionIndex,
    int? selectedOption,
    bool clearSelection = false,
    bool? markedForReview,
  }) {
    return _client.patch('/api/exam-sessions/$id/answer', body: {
      'questionIndex': questionIndex,
      if (clearSelection)
        'selectedOption': null
      else if (selectedOption != null)
        'selectedOption': selectedOption,
      if (markedForReview != null) 'markedForReview': markedForReview,
    });
  }

  Future<({int strikes, String status})> recordStrike(String id) async {
    final data = await _client.post('/api/exam-sessions/$id/strike');
    final result = data['result'] as Map<String, dynamic>;
    return (
      strikes: (result['strikes'] as num?)?.toInt() ?? 0,
      status: result['status'] as String? ?? 'in_progress',
    );
  }

  Future<ExamResult> submit(String id) async {
    final data = await _client.post('/api/exam-sessions/$id/submit');
    return ExamResult.fromJson(data['result'] as Map<String, dynamic>);
  }

  Future<ExamResult> getResult(String id) async {
    final data = await _client.get('/api/exam-sessions/$id/result');
    return ExamResult.fromJson(data['result'] as Map<String, dynamic>);
  }

  Future<List<SessionSummary>> listSessions() async {
    final data = await _client.get('/api/exam-sessions');
    return (data['sessions'] as List<dynamic>)
        .map((s) => SessionSummary.fromJson(s as Map<String, dynamic>))
        .toList();
  }

  Future<StudentStats> getStats() async {
    final data = await _client.get('/api/exam-sessions/stats');
    return StudentStats.fromJson(data['stats'] as Map<String, dynamic>);
  }
}
