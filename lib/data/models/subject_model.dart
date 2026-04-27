// lib/data/models/subject_model.dart
import '../../domain/entities/subject_entity.dart';
 
class SubjectModel extends SubjectEntity {
  const SubjectModel({
    super.id,
    required super.name,
    required super.icon,
    required super.totalQuestions,
    required super.colorHex,
  });
 
  factory SubjectModel.fromMap(Map<String, dynamic> map) => SubjectModel(
    id: map['id'] as int?,
    name: map['name'] as String,
    icon: map['icon'] as String,
    totalQuestions: map['total_questions'] as int? ?? 0,
    colorHex: map['color_hex'] as String,
  );
 
  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'icon': icon,
    'total_questions': totalQuestions,
    'color_hex': colorHex,
  };
}