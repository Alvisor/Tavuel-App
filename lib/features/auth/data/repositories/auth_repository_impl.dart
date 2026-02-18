import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/api/api_interceptors.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _datasource;
  final SecureStorageHelper _storage;

  AuthRepositoryImpl(this._datasource, this._storage);

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _datasource.login(
        email: email,
        password: password,
      );
      await _storage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      await _storage.saveUserId(response.user.id);
      return Result.success(response.user);
    } on UnauthorizedException {
      return Result.failure(
        const AuthFailure(message: 'Credenciales incorrectas.'),
      );
    } on AppException catch (e) {
      return Result.failure(Failure(message: e.message));
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<User>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    bool wantsToBeProvider = false,
  }) async {
    try {
      final response = await _datasource.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        wantsToBeProvider: wantsToBeProvider,
      );
      await _storage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      await _storage.saveUserId(response.user.id);
      return Result.success(response.user);
    } on AppException catch (e) {
      return Result.failure(Failure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<User>> googleSignIn() async {
    try {
      final googleSignIn = GoogleSignIn(scopes: ['email']);
      final account = await googleSignIn.signIn();

      if (account == null) {
        return Result.failure(
          const Failure(message: 'Inicio con Google cancelado.'),
        );
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken == null) {
        return Result.failure(
          const Failure(message: 'No se pudo obtener el token de Google.'),
        );
      }

      final response = await _datasource.googleSignIn(idToken: idToken);
      await _storage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      await _storage.saveUserId(response.user.id);
      return Result.success(response.user);
    } on AppException catch (e) {
      return Result.failure(Failure(message: e.message));
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error con Google Sign-In: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _datasource.logout();
      await _storage.clearTokens();
      return Result.success(null);
    } on AppException catch (e) {
      await _storage.clearTokens();
      return Result.failure(Failure(message: e.message));
    } catch (_) {
      await _storage.clearTokens();
      return Result.success(null);
    }
  }

  @override
  Future<Result<User>> getCurrentUser() async {
    try {
      final user = await _datasource.getCurrentUser();
      return Result.success(user);
    } on UnauthorizedException {
      await _storage.clearTokens();
      return Result.failure(
        const AuthFailure(message: 'Sesión expirada.'),
      );
    } on AppException catch (e) {
      return Result.failure(Failure(message: e.message));
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }
}
