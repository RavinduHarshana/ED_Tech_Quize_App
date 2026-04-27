import '../entities/question_entity.dart';
import '../../core/errors/failures.dart';
 
abstract class QuestionRepository {
  Future<(List<QuestionEntity>, Failure?)> getQuestionsBySubject(int subjectId);
}