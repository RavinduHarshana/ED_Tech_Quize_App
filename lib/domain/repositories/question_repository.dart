import '../entities/question_entity.dart';
import '../../core/errors/failures.dart';

abstract class QuestionRepository {
  Future<(List<QuestionEntity>, Failure?)> getQuestionsBySubject(int subjectId);
  Future<(List<QuestionEntity>, Failure?)> getAllQuestions();
  Future<(QuestionEntity?, Failure?)> getQuestionById(int questionId);
  Future<(int?, Failure?)> createQuestion(QuestionEntity question);
  Future<(bool, Failure?)> updateQuestion(QuestionEntity question);
  Future<(bool, Failure?)> deleteQuestion(int questionId);
}
