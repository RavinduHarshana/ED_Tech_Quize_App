// lib/domain/usecases/subject_usecases.dart
import '../entities/subject_entity.dart';
import '../repositories/subject_repository.dart';
import '../../core/errors/failures.dart';
 
class GetAllSubjectsUseCase {
  final SubjectRepository repo;
  GetAllSubjectsUseCase(this.repo);
  Future<(List<SubjectEntity>, Failure?)> call() => repo.getAllSubjects();
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