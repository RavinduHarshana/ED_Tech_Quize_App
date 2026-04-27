import '../entities/quiz_result_entity.dart';
import '../repositories/quiz_result_repository.dart';
import '../../core/errors/failures.dart';
 
class SaveQuizResultUseCase {
  final QuizResultRepository repo;
  SaveQuizResultUseCase(this.repo);
  Future<(bool, Failure?)> call(QuizResultEntity result) => repo.saveResult(result);
}
 
class GetUserResultsUseCase {
  final QuizResultRepository repo;
  GetUserResultsUseCase(this.repo);
  Future<(List<QuizResultEntity>, Failure?)> call(int userId) =>
      repo.getResultsByUser(userId);
}
 
class GetUserStatsUseCase {
  final QuizResultRepository repo;
  GetUserStatsUseCase(this.repo);
  Future<(Map<String, dynamic>, Failure?)> call(int userId) =>
      repo.getUserStats(userId);
}