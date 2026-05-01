// lib/domain/usecases/subject_usecases.dart
import '../entities/subject_entity.dart';
import '../repositories/subject_repository.dart';
import '../../core/errors/failures.dart';

class GetAllSubjectsUseCase {
  final SubjectRepository repo;
  GetAllSubjectsUseCase(this.repo);
  Future<(List<SubjectEntity>, Failure?)> call() => repo.getAllSubjects();
}

class GetSubjectByIdUseCase {
  final SubjectRepository repo;
  GetSubjectByIdUseCase(this.repo);
  Future<(SubjectEntity?, Failure?)> call(int subjectId) =>
      repo.getSubjectById(subjectId);
}

class CreateSubjectUseCase {
  final SubjectRepository repo;
  CreateSubjectUseCase(this.repo);
  Future<(int?, Failure?)> call(SubjectEntity subject) =>
      repo.createSubject(subject);
}

class UpdateSubjectUseCase {
  final SubjectRepository repo;
  UpdateSubjectUseCase(this.repo);
  Future<(bool, Failure?)> call(SubjectEntity subject) =>
      repo.updateSubject(subject);
}

class DeleteSubjectUseCase {
  final SubjectRepository repo;
  DeleteSubjectUseCase(this.repo);
  Future<(bool, Failure?)> call(int subjectId) => repo.deleteSubject(subjectId);
}

class GetFavoriteSubjectsUseCase {
  final SubjectRepository repo;
  GetFavoriteSubjectsUseCase(this.repo);
  Future<(List<SubjectEntity>, Failure?)> call(int userId) =>
      repo.getFavoriteSubjects(userId);
}

class ToggleFavoriteUseCase {
  final SubjectRepository repo;
  ToggleFavoriteUseCase(this.repo);
  Future<(bool, Failure?)> call(int userId, int subjectId) =>
      repo.toggleFavorite(userId, subjectId);
}
