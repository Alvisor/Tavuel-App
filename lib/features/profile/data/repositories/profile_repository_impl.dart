import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDatasource _datasource;

  ProfileRepositoryImpl(this._datasource);

  @override
  Future<Result<User>> getProfile() async {
    try {
      final user = await _datasource.getProfile();
      return Result.success(user);
    } on UnauthorizedException {
      return Result.failure(
        const AuthFailure(message: 'Sesión expirada. Inicia sesión nuevamente.'),
      );
    } on AppException catch (e) {
      return Result.failure(Failure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<User>> updateProfile(Map<String, dynamic> data) async {
    try {
      final user = await _datasource.updateProfile(data);
      return Result.success(user);
    } on AppException catch (e) {
      return Result.failure(Failure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<User>> toggleMode() async {
    try {
      final user = await _datasource.toggleMode();
      return Result.success(user);
    } on AppException catch (e) {
      return Result.failure(Failure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }
}
