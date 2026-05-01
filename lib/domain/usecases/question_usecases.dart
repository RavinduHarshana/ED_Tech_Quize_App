import '../entities/question_entity.dart';
import '../repositories/question_repository.dart';
import '../../core/errors/failures.dart';

class GetQuestionsBySubjectUseCase {
  final QuestionRepository repo;
  GetQuestionsBySubjectUseCase(this.repo);
  Future<(List<QuestionEntity>, Failure?)> call(int subjectId) =>
      repo.getQuestionsBySubject(subjectId);
}

class GetAllQuestionsUseCase {
  final QuestionRepository repo;
  GetAllQuestionsUseCase(this.repo);
  Future<(List<QuestionEntity>, Failure?)> call() => repo.getAllQuestions();
}

class GetQuestionByIdUseCase {
  final QuestionRepository repo;
  GetQuestionByIdUseCase(this.repo);
  Future<(QuestionEntity?, Failure?)> call(int questionId) =>
      repo.getQuestionById(questionId);
}

class CreateQuestionUseCase {
  final QuestionRepository repo;
  CreateQuestionUseCase(this.repo);
  Future<(int?, Failure?)> call(QuestionEntity question) =>
      repo.createQuestion(question);
}

class UpdateQuestionUseCase {
  final QuestionRepository repo;
  UpdateQuestionUseCase(this.repo);
  Future<(bool, Failure?)> call(QuestionEntity question) =>
      repo.updateQuestion(question);
}

class DeleteQuestionUseCase {
  final QuestionRepository repo;
  DeleteQuestionUseCase(this.repo);
  Future<(bool, Failure?)> call(int questionId) =>
      repo.deleteQuestion(questionId);
}
