// lib/data/models/quiz_result_model.dart
import '../../domain/entities/quiz_result_entity.dart';
 
class QuizResultModel extends QuizResultEntity {
  const QuizResultModel({
    super.id,
    required super.userId,
    required super.subjectId,
    required super.subjectName,
    required super.correct,
    required super.total,
    required super.scorePct,
    required super.takenAt,
  });
 
  factory QuizResultModel.fromMap(Map<String, dynamic> map) => QuizResultModel(
    id: map['id'] as int?,
    userId: map['user_id'] as int,
    subjectId: map['subject_id'] as int,
    subjectName: map['subject_name'] as String,
    correct: map['correct'] as int,
    total: map['total'] as int,
    scorePct: map['score_pct'] as int,
    takenAt: map['taken_at'] as String,
  );
 
  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'user_id': userId,
    'subject_id': subjectId,
    'subject_name': subjectName,
    'correct': correct,
    'total': total,
    'score_pct': scorePct,
    'taken_at': takenAt,
  };
 
  factory QuizResultModel.fromEntity(QuizResultEntity e) => QuizResultModel(
    id: e.id,
    userId: e.userId,
    subjectId: e.subjectId,
    subjectName: e.subjectName,
    correct: e.correct,
    total: e.total,
    scorePct: e.scorePct,
    takenAt: e.takenAt,
  );
}
 