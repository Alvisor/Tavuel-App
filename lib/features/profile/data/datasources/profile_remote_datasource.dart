import '../../../../core/api/api_client.dart';
import '../../../auth/data/models/user_model.dart';

class ProfileRemoteDatasource {
  final ApiClient _apiClient;

  ProfileRemoteDatasource(this._apiClient);

  /// Obtiene el perfil del usuario autenticado.
  Future<UserModel> getProfile() async {
    final response = await _apiClient.get('/users/me');
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Actualiza los datos del perfil del usuario autenticado.
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final response = await _apiClient.patch('/users/me', data: data);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Alterna entre modo CLIENTE y PROVEEDOR.
  Future<UserModel> toggleMode() async {
    final response = await _apiClient.patch('/users/me/toggle-mode', data: {});
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}
