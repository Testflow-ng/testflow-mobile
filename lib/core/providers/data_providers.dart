import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exam.dart';
import '../models/subject.dart';
import 'api_providers.dart';
import 'auth_provider.dart';

final subjectsProvider = FutureProvider<List<Subject>>((ref) {
  ref.watch(authProvider.select((s) => s.user?.id));
  return ref.watch(subjectRepositoryProvider).list();
});

final statsProvider = FutureProvider<StudentStats>((ref) {
  ref.watch(authProvider.select((s) => s.user?.id));
  return ref.watch(examRepositoryProvider).getStats();
});

final sessionsProvider = FutureProvider<List<SessionSummary>>((ref) {
  ref.watch(authProvider.select((s) => s.user?.id));
  return ref.watch(examRepositoryProvider).listSessions();
});

final leaderboardProvider =
    FutureProvider.family<List<LeaderboardEntry>, String>((ref, subjectId) {
  return ref.watch(subjectRepositoryProvider).leaderboard(subjectId);
});
