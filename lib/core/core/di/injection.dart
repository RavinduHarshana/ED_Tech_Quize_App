// lib/core/di/injection.dart
import 'package:get_it/get_it.dart';
import 'package:quize_app/domain/usecases/quiz_result_usecases.dart';
import '../../../data/datasources/local_datasource.dart';
import '../../../data/repositories/repositories_impl.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/question_repository.dart';
import '../../../domain/repositories/quiz_result_repository.dart';
import '../../../domain/repositories/subject_repository.dart';
import '../../../domain/usecases/auth_usecases.dart';
import '../../../domain/usecases/question_usecases.dart';
import '../../../domain/usecases/subject_usecases.dart';
import '../../database/database_helper.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── Core ──────────────────────────────────────
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());

  // ── Data Sources ──────────────────────────────
  sl.registerLazySingleton(() => AuthLocalDataSource(sl()));
  sl.registerLazySingleton(() => SubjectLocalDataSource(sl()));
  sl.registerLazySingleton(() => QuestionLocalDataSource(sl()));
  sl.registerLazySingleton(() => QuizResultLocalDataSource(sl()));

  // ── Repositories ──────────────────────────────
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<SubjectRepository>(
    () => SubjectRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<QuestionRepository>(
    () => QuestionRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<QuizResultRepository>(
    () => QuizResultRepositoryImpl(sl()),
  );

  // ── Use Cases ─────────────────────────────────
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserUseCase(sl()));

  sl.registerLazySingleton(() => GetAllSubjectsUseCase(sl()));
  sl.registerLazySingleton(() => GetSubjectByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateSubjectUseCase(sl()));
  sl.registerLazySingleton(() => UpdateSubjectUseCase(sl()));
  sl.registerLazySingleton(() => DeleteSubjectUseCase(sl()));
  sl.registerLazySingleton(() => GetFavoriteSubjectsUseCase(sl()));
  sl.registerLazySingleton(() => ToggleFavoriteUseCase(sl()));

  sl.registerLazySingleton(() => GetQuestionsBySubjectUseCase(sl()));
  sl.registerLazySingleton(() => GetAllQuestionsUseCase(sl()));
  sl.registerLazySingleton(() => GetQuestionByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateQuestionUseCase(sl()));
  sl.registerLazySingleton(() => UpdateQuestionUseCase(sl()));
  sl.registerLazySingleton(() => DeleteQuestionUseCase(sl()));

  sl.registerLazySingleton(() => SaveQuizResultUseCase(sl()));
  sl.registerLazySingleton(() => GetUserResultsUseCase(sl()));
  sl.registerLazySingleton(() => GetUserStatsUseCase(sl()));
}
