import '../../../../core/errors/failure.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Result<User>> login({
    required String email,
    required String password,
  });

  Future<Result<User>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  });

  Future<Result<User>> googleSignIn();

  Future<Result<void>> logout();

  Future<Result<User>> getCurrentUser();
}
