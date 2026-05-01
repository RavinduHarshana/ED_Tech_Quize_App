// lib/data/models/question_model.dart
import '../../domain/entities/question_entity.dart';

class QuestionModel extends QuestionEntity {
  const QuestionModel({
    super.id,
    required super.subjectId,
    required super.text,
    required super.options,
    required super.correctIndex,
  });

  factory QuestionModel.fromMap(Map<String, dynamic> map) => QuestionModel(
    id: map['id'] as int?,
    subjectId: map['subject_id'] as int,
    text: map['text'] as String,
    options: [
      map['option_a'] as String,
      map['option_b'] as String,
      map['option_c'] as String,
      map['option_d'] as String,
    ],
    correctIndex: map['correct_index'] as int,
  );

  factory QuestionModel.fromEntity(QuestionEntity entity) => QuestionModel(
    id: entity.id,
    subjectId: entity.subjectId,
    text: entity.text,
    options: entity.options,
    correctIndex: entity.correctIndex,
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'subject_id': subjectId,
    'text': text,
    'option_a': options[0],
    'option_b': options[1],
    'option_c': options[2],
    'option_d': options[3],
    'correct_index': correctIndex,
  };
}
