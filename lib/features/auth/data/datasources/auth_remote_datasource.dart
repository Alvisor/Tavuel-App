import '../../../../core/api/api_client.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

class AuthRemoteDatasource {
  final ApiClient _apiClient;

  AuthRemoteDatasource(this._apiClient);

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return AuthResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    final response = await _apiClient.post(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
      },
    );
    return AuthResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<void> logout() async {
    await _apiClient.post('/auth/logout');
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get('/users/me');
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }
}
