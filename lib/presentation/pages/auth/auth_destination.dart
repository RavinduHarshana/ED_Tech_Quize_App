// lib/presentation/pages/auth/auth_destination.dart
import 'package:flutter/material.dart';

import '../../../domain/entities/user_entity.dart';
import '../admin/admin_shell.dart';
import '../home/main_shell.dart';

Route<void> routeForUser(UserEntity user) {
  return MaterialPageRoute(
    builder: (_) => user.isAdmin ? const AdminShell() : const MainShell(),
  );
}
