import '../entities/subject_entity.dart';
import '../../core/errors/failures.dart';
 
abstract class SubjectRepository {
  Future<(List<SubjectEntity>, Failure?)> getAllSubjects();
  Future<(List<SubjectEntity>, Failure?)> getFavoriteSubjects(int userId);
  Future<(bool, Failure?)> toggleFavorite(int userId, int subjectId);
  Future<bool> isFavorite(int userId, int subjectId);
}
 