import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../models/availability_model.dart';
import '../models/bank_account_model.dart';
import '../models/onboarding_status_model.dart';
import '../models/provider_document_model.dart';
import '../models/service_category_model.dart';

class ProviderOnboardingRemoteDatasource {
  final ApiClient _apiClient;

  ProviderOnboardingRemoteDatasource(this._apiClient);

  /// Obtiene el perfil completo del proveedor con todas sus relaciones.
  /// GET /providers/me
  /// Retorna null si no tiene perfil.
  Future<Map<String, dynamic>?> getMyProfile() async {
    final response = await _apiClient.get('/providers/me');
    final data = response.data;
    if (data is Map<String, dynamic> && data['hasProfile'] == false) {
      return null;
    }
    return data as Map<String, dynamic>;
  }

  /// Crea el perfil de proveedor.
  /// POST /providers
  Future<void> createProfile({
    required String bio,
    required String address,
    required double latitude,
    required double longitude,
    required List<String> categoryIds,
  }) async {
    await _apiClient.post(
      '/providers',
      data: {
        'bio': bio,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'serviceCategoryIds': categoryIds,
      },
    );
  }

  /// Obtiene el estado del onboarding del proveedor actual.
  /// GET /providers/me/status
  Future<OnboardingStatusModel> getOnboardingStatus() async {
    final response = await _apiClient.get('/providers/me/status');
    return OnboardingStatusModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// Actualiza el perfil del proveedor actual.
  /// PATCH /providers/me
  Future<void> updateProfile({
    String? bio,
    String? address,
    double? latitude,
    double? longitude,
    List<String>? categoryIds,
  }) async {
    final data = <String, dynamic>{};
    if (bio != null) data['bio'] = bio;
    if (address != null) data['address'] = address;
    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;
    if (categoryIds != null) data['serviceCategoryIds'] = categoryIds;

    await _apiClient.patch('/providers/me', data: data);
  }

  /// Sube un documento del proveedor.
  /// POST /providers/me/documents (multipart)
  Future<ProviderDocumentModel> uploadDocument({
    required String filePath,
    required String documentType,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'type': documentType,
    });

    final response = await _apiClient.uploadFile(
      '/providers/me/documents',
      formData: formData,
    );

    return ProviderDocumentModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// Obtiene los documentos del proveedor actual.
  /// GET /providers/me/documents
  Future<List<ProviderDocumentModel>> getDocuments() async {
    final response = await _apiClient.get('/providers/me/documents');
    final list = response.data as List<dynamic>;
    return list
        .map((e) =>
            ProviderDocumentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Configura la cuenta bancaria del proveedor.
  /// POST /providers/me/bank
  Future<BankAccountModel> setBankAccount({
    required BankAccountModel bankAccount,
  }) async {
    final response = await _apiClient.post(
      '/providers/me/bank',
      data: bankAccount.toJson(),
    );
    return BankAccountModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// Obtiene la cuenta bancaria del proveedor actual.
  /// GET /providers/me/bank
  Future<BankAccountModel> getBankAccount() async {
    final response = await _apiClient.get('/providers/me/bank');
    return BankAccountModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  /// Configura la disponibilidad del proveedor.
  /// PUT /providers/me/availability
  Future<void> setAvailability({
    required List<AvailabilitySlotModel> slots,
  }) async {
    await _apiClient.put(
      '/providers/me/availability',
      data: {
        'slots': slots.map((s) => s.toJson()).toList(),
      },
    );
  }

  /// Obtiene la disponibilidad del proveedor actual.
  /// GET /providers/me/availability
  Future<List<AvailabilitySlotModel>> getAvailability() async {
    final response = await _apiClient.get('/providers/me/availability');
    final list = response.data as List<dynamic>;
    return list
        .map((e) =>
            AvailabilitySlotModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Envia el perfil para verificacion.
  /// POST /providers/me/submit
  Future<void> submitForVerification() async {
    await _apiClient.post('/providers/me/submit', data: {});
  }

  /// Obtiene las categorias de servicios disponibles.
  /// GET /services/categories
  Future<List<ServiceCategoryModel>> getCategories() async {
    final response = await _apiClient.get('/services/categories');
    final list = response.data as List<dynamic>;
    return list
        .map((e) =>
            ServiceCategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
