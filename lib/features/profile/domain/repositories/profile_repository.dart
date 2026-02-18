import '../../../../core/errors/failure.dart';
import '../../../auth/domain/entities/user.dart';

abstract class ProfileRepository {
  /// Obtiene el perfil del usuario autenticado.
  Future<Result<User>> getProfile();

  /// Actualiza los datos del perfil.
  Future<Result<User>> updateProfile(Map<String, dynamic> data);

  /// Alterna entre modo CLIENTE y PROVEEDOR.
  Future<Result<User>> toggleMode();
}
