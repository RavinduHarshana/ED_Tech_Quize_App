import '../entities/quiz_result_entity.dart';
import '../../core/errors/failures.dart';
 
abstract class QuizResultRepository {
  Future<(bool, Failure?)> saveResult(QuizResultEntity result);
  Future<(List<QuizResultEntity>, Failure?)> getResultsByUser(int userId);
  Future<(Map<String, dynamic>, Failure?)> getUserStats(int userId);
}