// lib/domain/usecases/auth_usecases.dart
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import '../../core/errors/failures.dart';
 
class LoginUseCase {
  final AuthRepository repo;
  LoginUseCase(this.repo);
  Future<(UserEntity?, Failure?)> call(String email, String password) =>
      repo.login(email, password);
}
 
class RegisterUseCase {
  final AuthRepository repo;
  RegisterUseCase(this.repo);
  Future<(UserEntity?, Failure?)> call(String name, String email, String password) =>
      repo.register(name, email, password);
}
 
class GetCurrentUserUseCase {
  final AuthRepository repo;
  GetCurrentUserUseCase(this.repo);
  Future<UserEntity?> call() async {
    final id = await repo.getLoggedInUserId();
    if (id == null) return null;
    final (user, _) = await repo.getUserById(id);
    return user;
  }
}
 
class LogoutUseCase {
  final AuthRepository repo;
  LogoutUseCase(this.repo);
  Future<void> call() => repo.logout();
}
 
class UpdateUserUseCase {
  final AuthRepository repo;
  UpdateUserUseCase(this.repo);
  Future<(bool, Failure?)> call(UserEntity user) => repo.updateUser(user);
}