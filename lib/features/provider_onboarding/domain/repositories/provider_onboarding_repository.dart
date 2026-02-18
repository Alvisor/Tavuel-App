import '../../../../core/errors/failure.dart';
import '../entities/availability_slot.dart';
import '../entities/bank_account.dart';
import '../entities/onboarding_status.dart';
import '../entities/provider_document.dart';
import '../entities/service_category.dart';

abstract class ProviderOnboardingRepository {
  /// Obtiene el perfil completo del proveedor desde el backend.
  /// Retorna null si no tiene perfil creado aún.
  Future<Result<Map<String, dynamic>?>> getMyProfile();

  /// Crea el perfil de proveedor con datos iniciales.
  Future<Result<void>> createProfile({
    required String bio,
    required String address,
    required double latitude,
    required double longitude,
    required List<String> categoryIds,
  });

  /// Obtiene el estado actual del onboarding.
  Future<Result<OnboardingStatus>> getOnboardingStatus();

  /// Actualiza el perfil del proveedor.
  Future<Result<void>> updateProfile({
    String? bio,
    String? address,
    double? latitude,
    double? longitude,
    List<String>? categoryIds,
  });

  /// Sube un documento de verificacion.
  Future<Result<ProviderDocument>> uploadDocument({
    required String filePath,
    required String documentType,
  });

  /// Obtiene los documentos subidos.
  Future<Result<List<ProviderDocument>>> getDocuments();

  /// Configura la cuenta bancaria.
  Future<Result<BankAccount>> setBankAccount({
    required BankAccount bankAccount,
  });

  /// Obtiene la cuenta bancaria configurada.
  Future<Result<BankAccount>> getBankAccount();

  /// Configura la disponibilidad horaria.
  Future<Result<void>> setAvailability({
    required List<AvailabilitySlot> slots,
  });

  /// Obtiene la disponibilidad horaria configurada.
  Future<Result<List<AvailabilitySlot>>> getAvailability();

  /// Envia el perfil para revision y verificacion.
  Future<Result<void>> submitForVerification();

  /// Obtiene las categorias de servicios disponibles.
  Future<Result<List<ServiceCategory>>> getCategories();
}
