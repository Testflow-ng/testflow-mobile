import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../repositories/auth_repository.dart';
import '../repositories/exam_repository.dart';
import '../repositories/subject_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  throw UnimplementedError('Override this in main()');
});

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider)),
);

final subjectRepositoryProvider = Provider<SubjectRepository>(
  (ref) => SubjectRepository(ref.watch(apiClientProvider)),
);

final examRepositoryProvider = Provider<ExamRepository>(
  (ref) => ExamRepository(ref.watch(apiClientProvider)),
);
