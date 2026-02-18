import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../provider_onboarding/data/datasources/provider_onboarding_remote_datasource.dart';

// ──────────────────────────────────────────────
// Entity
// ──────────────────────────────────────────────

/// Representa un servicio vinculado al proveedor.
@immutable
class ProviderServiceItem {
  final String id;
  final String serviceId;
  final String serviceName;
  final String categoryName;
  final String categorySlug;
  final double price;
  final bool isActive;

  const ProviderServiceItem({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.categoryName,
    required this.categorySlug,
    required this.price,
    required this.isActive,
  });

  factory ProviderServiceItem.fromJson(Map<String, dynamic> json) {
    final service = json['service'] as Map<String, dynamic>? ?? {};
    final category = service['category'] as Map<String, dynamic>? ?? {};

    return ProviderServiceItem(
      id: json['id'] as String? ?? '',
      serviceId: json['serviceId'] as String? ?? '',
      serviceName: service['name'] as String? ?? '',
      categoryName: category['name'] as String? ?? '',
      categorySlug: category['slug'] as String? ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

// ──────────────────────────────────────────────
// State
// ──────────────────────────────────────────────

@immutable
class ProviderServicesState {
  final List<ProviderServiceItem> services;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const ProviderServicesState({
    this.services = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  ProviderServicesState copyWith({
    List<ProviderServiceItem>? services,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool clearError = false,
  }) {
    return ProviderServicesState(
      services: services ?? this.services,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// Servicios agrupados por nombre de categoría.
  Map<String, List<ProviderServiceItem>> get servicesByCategory {
    final grouped = <String, List<ProviderServiceItem>>{};
    for (final service in services) {
      final key = service.categoryName.isNotEmpty
          ? service.categoryName
          : 'Sin categoría';
      grouped.putIfAbsent(key, () => []).add(service);
    }
    return grouped;
  }
}

// ──────────────────────────────────────────────
// Notifier
// ──────────────────────────────────────────────

class ProviderServicesNotifier extends StateNotifier<ProviderServicesState> {
  final ProviderOnboardingRemoteDatasource _datasource;

  ProviderServicesNotifier(this._datasource)
      : super(const ProviderServicesState());

  /// Carga los servicios del proveedor desde GET /providers/me.
  Future<void> loadMyServices() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final profileData = await _datasource.getMyProfile();
      if (profileData == null) {
        state = state.copyWith(isLoading: false, services: []);
        return;
      }

      final servicesJson = profileData['services'] as List<dynamic>? ?? [];
      final services = servicesJson
          .map((s) => ProviderServiceItem.fromJson(s as Map<String, dynamic>))
          .toList();

      state = state.copyWith(isLoading: false, services: services);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al cargar los servicios: ${e.toString()}',
      );
    }
  }

  /// Actualiza las categorías del proveedor vía PATCH /providers/me.
  Future<bool> updateCategories(List<String> categoryIds) async {
    state = state.copyWith(isSaving: true, clearError: true);

    try {
      await _datasource.updateProfile(categoryIds: categoryIds);
      // Recargar servicios después de actualizar
      await loadMyServices();
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Error al actualizar las categorías: ${e.toString()}',
      );
      return false;
    }
  }

  /// Limpia el error actual.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// ──────────────────────────────────────────────
// Providers
// ──────────────────────────────────────────────

final providerServicesProvider =
    StateNotifierProvider<ProviderServicesNotifier, ProviderServicesState>(
        (ref) {
  final datasource =
      ProviderOnboardingRemoteDatasource(ref.read(apiClientProvider));
  return ProviderServicesNotifier(datasource);
});

/// Provider que carga y expone los category IDs seleccionados del proveedor.
/// Hace una llamada a GET /providers/me para extraer los IDs reales de categoría
/// desde el array de servicios vinculados.
final mySelectedCategoryIdsFutureProvider =
    FutureProvider<Set<String>>((ref) async {
  final datasource =
      ProviderOnboardingRemoteDatasource(ref.read(apiClientProvider));
  final profileData = await datasource.getMyProfile();

  if (profileData == null) return {};

  final servicesJson = profileData['services'] as List<dynamic>? ?? [];
  final categoryIds = <String>{};

  for (final ps in servicesJson) {
    final service = (ps as Map<String, dynamic>)['service'];
    if (service is Map<String, dynamic>) {
      final category = service['category'];
      if (category is Map<String, dynamic>) {
        final catId = category['id'] as String?;
        if (catId != null) categoryIds.add(catId);
      }
    }
  }

  return categoryIds;
});
