// lib/domain/entities/question_entity.dart
import 'package:equatable/equatable.dart';

class QuestionEntity extends Equatable {
  final int? id;
  final int subjectId;
  final String text;
  final List<String> options;
  final int correctIndex;

  const QuestionEntity({
    this.id,
    required this.subjectId,
    required this.text,
    required this.options,
    required this.correctIndex,
  });

  @override
  List<Object?> get props => [id, text];
}