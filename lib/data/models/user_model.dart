// lib/data/models/user_model.dart
import '../../domain/entities/user_entity.dart';
 
class UserModel extends UserEntity {
  const UserModel({
    super.id,
    required super.name,
    required super.email,
    required super.passwordHash,
    super.avatarPath,
    super.xpPoints,
    super.trophyCount,
    required super.createdAt,
  });
 
  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id: map['id'] as int?,
    name: map['name'] as String,
    email: map['email'] as String,
    passwordHash: map['password_hash'] as String,
    avatarPath: map['avatar_path'] as String?,
    xpPoints: map['xp_points'] as int? ?? 0,
    trophyCount: map['trophy_count'] as int? ?? 0,
    createdAt: map['created_at'] as String,
  );
 
  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'email': email,
    'password_hash': passwordHash,
    'avatar_path': avatarPath,
    'xp_points': xpPoints,
    'trophy_count': trophyCount,
    'created_at': createdAt,
  };
 
  factory UserModel.fromEntity(UserEntity entity) => UserModel(
    id: entity.id,
    name: entity.name,
    email: entity.email,
    passwordHash: entity.passwordHash,
    avatarPath: entity.avatarPath,
    xpPoints: entity.xpPoints,
    trophyCount: entity.trophyCount,
    createdAt: entity.createdAt,
  );
}