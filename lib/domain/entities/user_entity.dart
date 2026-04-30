// lib/domain/entities/user_entity.dart
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int? id;
  final String name;
  final String email;
  final String passwordHash;
  final String? avatarPath;
  final int xpPoints;
  final int role; // 0 = user, 1 = admin
  final int trophyCount;
  final String createdAt;

  const UserEntity({
    this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    this.avatarPath,
    this.xpPoints = 0,
    this.role = 0,
    this.trophyCount = 0,
    required this.createdAt,
  });

  UserEntity copyWith({
    int? id,
    String? name,
    String? email,
    String? passwordHash,
    String? avatarPath,
    int? xpPoints,
    int? role,
    int? trophyCount,
    String? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      avatarPath: avatarPath ?? this.avatarPath,
      xpPoints: xpPoints ?? this.xpPoints,
      role: role ?? this.role,
      trophyCount: trophyCount ?? this.trophyCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isAdmin => role == 1;

  @override
  List<Object?> get props => [id, name, email, xpPoints, role, trophyCount];
}
