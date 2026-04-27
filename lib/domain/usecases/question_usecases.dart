import '../entities/question_entity.dart';
import '../repositories/question_repository.dart';
import '../../core/errors/failures.dart';
 
class GetQuestionsBySubjectUseCase {
  final QuestionRepository repo;
  GetQuestionsBySubjectUseCase(this.repo);
  Future<(List<QuestionEntity>, Failure?)> call(int subjectId) =>
      repo.getQuestionsBySubject(subjectId);
}