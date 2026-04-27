// lib/domain/entities/subject_entity.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SubjectEntity extends Equatable {
  final int? id;
  final String name;
  final String icon;
  final int totalQuestions;
  final String colorHex;

  const SubjectEntity({
    this.id,
    required this.name,
    required this.icon,
    required this.totalQuestions,
    required this.colorHex,
  });

  Color get color => Color(int.parse('FF$colorHex', radix: 16));

  @override
  List<Object?> get props => [id, name];
}