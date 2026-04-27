import '../entities/user_entity.dart';
import '../../core/errors/failures.dart';
 
abstract class AuthRepository {
  Future<(UserEntity?, Failure?)> login(String email, String password);
  Future<(UserEntity?, Failure?)> register(String name, String email, String password);
  Future<(UserEntity?, Failure?)> getUserById(int id);
  Future<(bool, Failure?)> updateUser(UserEntity user);
  Future<void> logout();
  Future<int?> getLoggedInUserId();
}