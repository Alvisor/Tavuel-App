import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/errors/failure.dart';
import '../../data/datasources/provider_onboarding_remote_datasource.dart';
import '../../data/models/availability_model.dart';
import '../../data/models/bank_account_model.dart';
import '../../data/models/provider_document_model.dart';
import '../../data/repositories/provider_onboarding_repository_impl.dart';
import '../../domain/entities/availability_slot.dart';
import '../../domain/entities/bank_account.dart';
import '../../domain/entities/onboarding_status.dart';
import '../../domain/entities/provider_document.dart';
import '../../domain/entities/service_category.dart';
import '../../domain/repositories/provider_onboarding_repository.dart';

// ──────────────────────────────────────────────
// DI Providers
// ──────────────────────────────────────────────

final providerOnboardingDatasourceProvider =
    Provider<ProviderOnboardingRemoteDatasource>((ref) {
  return ProviderOnboardingRemoteDatasource(ref.read(apiClientProvider));
});

final providerOnboardingRepositoryProvider =
    Provider<ProviderOnboardingRepository>((ref) {
  return ProviderOnboardingRepositoryImpl(
    ref.read(providerOnboardingDatasourceProvider),
  );
});

/// Carga las categorias de servicio desde el API.
final serviceCategoriesProvider =
    FutureProvider<List<ServiceCategory>>((ref) async {
  final repository = ref.read(providerOnboardingRepositoryProvider);
  final result = await repository.getCategories();
  return result.when(
    success: (categories) => categories,
    failure: (failure) => throw Exception(failure.message),
  );
});

// ──────────────────────────────────────────────
// State
// ──────────────────────────────────────────────

@immutable
class OnboardingWizardState {
  final int currentStep;
  final bool isLoading;
  final String? error;
  final OnboardingStatus onboardingStatus;
  final List<ServiceCategory> categories;
  final List<ProviderDocument> documents;
  final BankAccount? bankAccount;
  final List<AvailabilitySlot> availability;
  final List<String> selectedCategoryIds;
  final String bio;
  final String address;
  final double? lat;
  final double? lng;
  final bool isSubmitted;
  final Map<String, double> uploadProgress;

  const OnboardingWizardState({
    this.currentStep = 0,
    this.isLoading = false,
    this.error,
    this.onboardingStatus = const OnboardingStatus(),
    this.categories = const [],
    this.documents = const [],
    this.bankAccount,
    this.availability = const [],
    this.selectedCategoryIds = const [],
    this.bio = '',
    this.address = '',
    this.lat,
    this.lng,
    this.isSubmitted = false,
    this.uploadProgress = const {},
  });

  OnboardingWizardState copyWith({
    int? currentStep,
    bool? isLoading,
    String? error,
    bool clearError = false,
    OnboardingStatus? onboardingStatus,
    List<ServiceCategory>? categories,
    List<ProviderDocument>? documents,
    BankAccount? bankAccount,
    bool clearBankAccount = false,
    List<AvailabilitySlot>? availability,
    List<String>? selectedCategoryIds,
    String? bio,
    String? address,
    double? lat,
    double? lng,
    bool? isSubmitted,
    Map<String, double>? uploadProgress,
  }) {
    return OnboardingWizardState(
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      onboardingStatus: onboardingStatus ?? this.onboardingStatus,
      categories: categories ?? this.categories,
      documents: documents ?? this.documents,
      bankAccount:
          clearBankAccount ? null : (bankAccount ?? this.bankAccount),
      availability: availability ?? this.availability,
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
      bio: bio ?? this.bio,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }

  /// Numero total de pasos del wizard.
  static const int totalSteps = 6;

  /// Nombres de cada paso para el indicador.
  static const List<String> stepLabels = [
    'Perfil',
    'Categorías',
    'Documentos',
    'Banco',
    'Horario',
    'Revisar',
  ];
}

// ──────────────────────────────────────────────
// Notifier
// ──────────────────────────────────────────────

class OnboardingWizardNotifier extends StateNotifier<OnboardingWizardState> {
  final ProviderOnboardingRepository _repository;

  OnboardingWizardNotifier(this._repository)
      : super(const OnboardingWizardState());

  /// Inicializa el wizard cargando todo desde el backend.
  ///
  /// Hace solo 2 llamadas al API:
  /// 1. GET /providers/me → perfil completo con relaciones
  /// 2. GET /services/categories → categorías disponibles
  ///
  /// Toda la información se deriva del backend (fuente de verdad).
  /// No se usa almacenamiento local para el progreso del onboarding.
  Future<void> init() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Cargar perfil completo y categorías en paralelo
      final results = await Future.wait([
        _repository.getMyProfile(),
        _repository.getCategories(),
      ]);

      final profileResult = results[0] as Result<Map<String, dynamic>?>;
      final categoriesResult = results[1] as Result<List<ServiceCategory>>;

      List<ServiceCategory> categories = [];
      categoriesResult.when(
        success: (cats) => categories = cats,
        failure: (f) => _setError(f),
      );

      // Si no hay perfil aún, mostrar desde el paso 0
      Map<String, dynamic>? profileData;
      profileResult.when(
        success: (data) => profileData = data,
        failure: (f) => _setError(f),
      );

      if (profileData == null) {
        state = state.copyWith(
          isLoading: false,
          categories: categories,
          onboardingStatus: const OnboardingStatus(),
          currentStep: 0,
        );
        return;
      }

      // Extraer datos del perfil para pre-llenar formularios
      final bio = profileData!['bio'] as String? ?? '';
      final address = profileData!['address'] as String? ?? '';
      // Prisma Decimal fields may come as strings — parse defensively
      final lat = double.tryParse(profileData!['latitude']?.toString() ?? '');
      final lng = double.tryParse(profileData!['longitude']?.toString() ?? '');

      // Extraer documentos
      final docsJson = profileData!['documents'] as List<dynamic>? ?? [];
      final documents = docsJson
          .map((d) =>
              ProviderDocumentModel.fromJson(d as Map<String, dynamic>)
                  as ProviderDocument)
          .toList();

      // Extraer cuenta bancaria
      BankAccount? bankAccount;
      final bankJson = profileData!['bankAccount'];
      if (bankJson is Map<String, dynamic>) {
        bankAccount = BankAccountModel.fromJson(bankJson);
      }

      // Extraer disponibilidad
      final availJson = profileData!['availability'] as List<dynamic>? ?? [];
      final availability = availJson
          .map((a) =>
              AvailabilitySlotModel.fromJson(a as Map<String, dynamic>)
                  as AvailabilitySlot)
          .toList();

      // Extraer IDs de categorías seleccionadas desde los servicios vinculados
      final servicesJson = profileData!['services'] as List<dynamic>? ?? [];
      final selectedCategoryIds = <String>{};
      for (final ps in servicesJson) {
        final service = (ps as Map<String, dynamic>)['service'];
        if (service is Map<String, dynamic>) {
          final category = service['category'];
          if (category is Map<String, dynamic>) {
            final catId = category['id'] as String?;
            if (catId != null) selectedCategoryIds.add(catId);
          }
        }
      }

      // Construir el estado de onboarding desde los datos reales
      final requiredDocTypes = {
        'CEDULA_FRONT', 'CEDULA_BACK', 'SELFIE_WITH_CEDULA',
        'RUT', 'ANTECEDENTES', 'BANK_CERTIFICATE',
      };
      final uploadedDocTypes = documents.map((d) => d.type).toSet();
      final documentsUploaded =
          requiredDocTypes.difference(uploadedDocTypes).isEmpty;

      final onboardingStatus = OnboardingStatus(
        hasProfile: true,
        profileComplete: bio.isNotEmpty && address.isNotEmpty,
        categoriesSelected: selectedCategoryIds.isNotEmpty,
        documentsUploaded: documentsUploaded,
        bankAccountSet: bankAccount != null,
        availabilitySet: availability.isNotEmpty,
        canSubmit: bio.isNotEmpty &&
            address.isNotEmpty &&
            selectedCategoryIds.isNotEmpty &&
            documentsUploaded &&
            bankAccount != null &&
            availability.isNotEmpty,
        verificationStatus:
            profileData!['verificationStatus'] as String?,
      );

      final initialStep = onboardingStatus.firstIncompleteStep;

      state = state.copyWith(
        isLoading: false,
        onboardingStatus: onboardingStatus,
        categories: categories,
        documents: documents,
        bankAccount: bankAccount,
        availability: availability,
        selectedCategoryIds: selectedCategoryIds.toList(),
        bio: bio,
        address: address,
        lat: lat,
        lng: lng,
        currentStep: initialStep,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar los datos: ${e.toString()}',
      );
    }
  }

  /// Guarda el paso 1: perfil bio + direccion.
  Future<bool> saveProfileStep({
    required String bio,
    required String address,
    required double lat,
    required double lng,
    required List<String> categoryIds,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    Result<void> result;

    if (state.onboardingStatus.hasProfile) {
      result = await _repository.updateProfile(
        bio: bio,
        address: address,
        latitude: lat,
        longitude: lng,
        categoryIds: categoryIds,
      );
    } else {
      result = await _repository.createProfile(
        bio: bio,
        address: address,
        latitude: lat,
        longitude: lng,
        categoryIds: categoryIds,
      );

      // Fallback: si createProfile falla con conflicto, intentar updateProfile
      final isConflict = result.when(
        success: (_) => false,
        failure: (f) => f.statusCode == 409 || f.message.contains('already exists'),
      );

      if (isConflict) {
        result = await _repository.updateProfile(
          bio: bio,
          address: address,
          latitude: lat,
          longitude: lng,
          categoryIds: categoryIds,
        );
      }
    }

    return result.when(
      success: (_) {
        state = state.copyWith(
          isLoading: false,
          bio: bio,
          address: address,
          lat: lat,
          lng: lng,
          selectedCategoryIds: categoryIds,
          onboardingStatus: OnboardingStatus(
            hasProfile: true,
            profileComplete: true,
            documentsUploaded: state.onboardingStatus.documentsUploaded,
            bankAccountSet: state.onboardingStatus.bankAccountSet,
            availabilitySet: state.onboardingStatus.availabilitySet,
            categoriesSelected:
                categoryIds.isNotEmpty || state.onboardingStatus.categoriesSelected,
            canSubmit: state.onboardingStatus.canSubmit,
            verificationStatus: state.onboardingStatus.verificationStatus,
          ),
        );
        return true;
      },
      failure: (f) {
        _setError(f);
        state = state.copyWith(isLoading: false);
        return false;
      },
    );
  }

  /// Guarda el paso 2: categorias seleccionadas.
  Future<bool> saveCategoriesStep(List<String> categoryIds) async {
    if (categoryIds.isEmpty) {
      state = state.copyWith(
        error: 'Debes seleccionar al menos una categoría.',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.updateProfile(categoryIds: categoryIds);

    return result.when(
      success: (_) {
        state = state.copyWith(
          isLoading: false,
          selectedCategoryIds: categoryIds,
          onboardingStatus: OnboardingStatus(
            hasProfile: state.onboardingStatus.hasProfile,
            profileComplete: state.onboardingStatus.profileComplete,
            documentsUploaded: state.onboardingStatus.documentsUploaded,
            bankAccountSet: state.onboardingStatus.bankAccountSet,
            availabilitySet: state.onboardingStatus.availabilitySet,
            categoriesSelected: true,
            canSubmit: state.onboardingStatus.canSubmit,
            verificationStatus: state.onboardingStatus.verificationStatus,
          ),
        );
        return true;
      },
      failure: (f) {
        _setError(f);
        state = state.copyWith(isLoading: false);
        return false;
      },
    );
  }

  /// Sube un documento individual.
  Future<bool> uploadDocument({
    required String filePath,
    required String documentType,
  }) async {
    state = state.copyWith(clearError: true);

    // Establecer progreso inicial
    final progressMap = Map<String, double>.from(state.uploadProgress);
    progressMap[documentType] = 0.0;
    state = state.copyWith(uploadProgress: progressMap);

    final result = await _repository.uploadDocument(
      filePath: filePath,
      documentType: documentType,
    );

    return result.when(
      success: (document) {
        // Actualizar la lista de documentos
        final updatedDocs = List<ProviderDocument>.from(state.documents);
        final existingIndex =
            updatedDocs.indexWhere((d) => d.type == documentType);
        if (existingIndex >= 0) {
          updatedDocs[existingIndex] = document;
        } else {
          updatedDocs.add(document);
        }

        // Limpiar progreso
        final cleanProgress = Map<String, double>.from(state.uploadProgress);
        cleanProgress.remove(documentType);

        state = state.copyWith(
          documents: updatedDocs,
          uploadProgress: cleanProgress,
        );
        return true;
      },
      failure: (f) {
        // Limpiar progreso en error
        final cleanProgress = Map<String, double>.from(state.uploadProgress);
        cleanProgress.remove(documentType);
        state = state.copyWith(uploadProgress: cleanProgress);
        _setError(f);
        return false;
      },
    );
  }

  /// Guarda la cuenta bancaria.
  Future<bool> saveBankAccount(BankAccount bankAccount) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.setBankAccount(
      bankAccount: bankAccount,
    );

    return result.when(
      success: (savedBank) {
        state = state.copyWith(
          isLoading: false,
          bankAccount: savedBank,
          onboardingStatus: OnboardingStatus(
            hasProfile: state.onboardingStatus.hasProfile,
            profileComplete: state.onboardingStatus.profileComplete,
            documentsUploaded: state.onboardingStatus.documentsUploaded,
            bankAccountSet: true,
            availabilitySet: state.onboardingStatus.availabilitySet,
            categoriesSelected: state.onboardingStatus.categoriesSelected,
            canSubmit: state.onboardingStatus.canSubmit,
            verificationStatus: state.onboardingStatus.verificationStatus,
          ),
        );
        return true;
      },
      failure: (f) {
        _setError(f);
        state = state.copyWith(isLoading: false);
        return false;
      },
    );
  }

  /// Guarda la disponibilidad horaria.
  Future<bool> saveAvailability(List<AvailabilitySlot> slots) async {
    if (slots.isEmpty) {
      state = state.copyWith(
        error: 'Debes configurar al menos un horario.',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.setAvailability(slots: slots);

    return result.when(
      success: (_) {
        state = state.copyWith(
          isLoading: false,
          availability: slots,
          onboardingStatus: OnboardingStatus(
            hasProfile: state.onboardingStatus.hasProfile,
            profileComplete: state.onboardingStatus.profileComplete,
            documentsUploaded: state.onboardingStatus.documentsUploaded,
            bankAccountSet: state.onboardingStatus.bankAccountSet,
            availabilitySet: true,
            categoriesSelected: state.onboardingStatus.categoriesSelected,
            canSubmit: state.onboardingStatus.canSubmit,
            verificationStatus: state.onboardingStatus.verificationStatus,
          ),
        );
        return true;
      },
      failure: (f) {
        _setError(f);
        state = state.copyWith(isLoading: false);
        return false;
      },
    );
  }

  /// Envia el perfil para verificacion.
  Future<bool> submitForVerification() async {
    // Refrescar estado antes de enviar
    final statusResult = await _repository.getOnboardingStatus();
    final latestStatus = statusResult.when(
      success: (status) => status,
      failure: (_) => state.onboardingStatus,
    );

    if (!latestStatus.canSubmit) {
      state = state.copyWith(
        error: 'Completa todos los pasos antes de enviar tu solicitud.',
        onboardingStatus: latestStatus,
      );
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.submitForVerification();

    return result.when(
      success: (_) {
        state = state.copyWith(
          isLoading: false,
          isSubmitted: true,
        );
        return true;
      },
      failure: (f) {
        _setError(f);
        state = state.copyWith(isLoading: false);
        return false;
      },
    );
  }

  /// Navega a un paso especifico.
  void goToStep(int step) {
    if (step >= 0 && step < OnboardingWizardState.totalSteps) {
      state = state.copyWith(currentStep: step, clearError: true);
    }
  }

  /// Avanza al siguiente paso.
  void nextStep() {
    if (state.currentStep < OnboardingWizardState.totalSteps - 1) {
      state = state.copyWith(
        currentStep: state.currentStep + 1,
        clearError: true,
      );
    }
  }

  /// Retrocede al paso anterior.
  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(
        currentStep: state.currentStep - 1,
        clearError: true,
      );
    }
  }

  /// Limpia el error actual.
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void _setError(Failure failure) {
    state = state.copyWith(error: failure.message);
  }
}

// ──────────────────────────────────────────────
// Main provider
// ──────────────────────────────────────────────

final onboardingWizardProvider =
    StateNotifierProvider<OnboardingWizardNotifier, OnboardingWizardState>(
        (ref) {
  return OnboardingWizardNotifier(
    ref.read(providerOnboardingRepositoryProvider),
  );
});
