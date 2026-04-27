// lib/domain/entities/quiz_result_entity.dart
import 'package:equatable/equatable.dart';

class QuizResultEntity extends Equatable {
  final int? id;
  final int userId;
  final int subjectId;
  final String subjectName;
  final int correct;
  final int total;
  final int scorePct;
  final String takenAt;

  const QuizResultEntity({
    this.id,
    required this.userId,
    required this.subjectId,
    required this.subjectName,
    required this.correct,
    required this.total,
    required this.scorePct,
    required this.takenAt,
  });

  @override
  List<Object?> get props => [id, userId, subjectId, takenAt];
}