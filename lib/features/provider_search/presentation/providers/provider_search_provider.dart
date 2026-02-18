import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/datasources/provider_search_remote_datasource.dart';
import '../../data/repositories/provider_search_repository_impl.dart';
import '../../domain/entities/provider_search_result.dart';
import '../../domain/entities/service_category.dart';
import '../../domain/repositories/provider_search_repository.dart';

// ── Dependency Injection ────────────────────────

final providerSearchDatasourceProvider =
    Provider<ProviderSearchRemoteDatasource>((ref) {
  return ProviderSearchRemoteDatasource(ref.read(apiClientProvider));
});

final providerSearchRepositoryProvider =
    Provider<ProviderSearchRepository>((ref) {
  return ProviderSearchRepositoryImpl(
    ref.read(providerSearchDatasourceProvider),
  );
});

// ── Search State ────────────────────────────────

class ProviderSearchState {
  final List<ProviderSearchResult> providers;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String? errorMessage;

  // Filtros activos
  final String? searchQuery;
  final String? selectedCategoryId;
  final String? selectedCategorySlug;
  final double? minRating;
  final String sortBy;
  final double? latitude;
  final double? longitude;

  const ProviderSearchState({
    this.providers = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.errorMessage,
    this.searchQuery,
    this.selectedCategoryId,
    this.selectedCategorySlug,
    this.minRating,
    this.sortBy = 'rating',
    this.latitude,
    this.longitude,
  });

  ProviderSearchState copyWith({
    List<ProviderSearchResult>? providers,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? errorMessage,
    String? searchQuery,
    String? selectedCategoryId,
    String? selectedCategorySlug,
    double? minRating,
    String? sortBy,
    double? latitude,
    double? longitude,
    // Flags para limpiar valores nulos
    bool clearError = false,
    bool clearCategory = false,
    bool clearMinRating = false,
    bool clearQuery = false,
  }) {
    return ProviderSearchState(
      providers: providers ?? this.providers,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchQuery: clearQuery ? null : (searchQuery ?? this.searchQuery),
      selectedCategoryId: clearCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      selectedCategorySlug: clearCategory
          ? null
          : (selectedCategorySlug ?? this.selectedCategorySlug),
      minRating:
          clearMinRating ? null : (minRating ?? this.minRating),
      sortBy: sortBy ?? this.sortBy,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  /// Indica si hay algun filtro activo.
  bool get hasActiveFilters =>
      selectedCategoryId != null ||
      selectedCategorySlug != null ||
      minRating != null ||
      sortBy != 'rating';
}

// ── Search Notifier ─────────────────────────────

class ProviderSearchNotifier extends StateNotifier<ProviderSearchState> {
  final ProviderSearchRepository _repository;

  ProviderSearchNotifier(this._repository)
      : super(const ProviderSearchState());

  /// Realiza la busqueda inicial (pagina 1). Reemplaza los resultados.
  Future<void> search() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      currentPage: 1,
      hasMore: true,
    );

    final result = await _repository.searchProviders(
      query: state.searchQuery,
      categoryId: state.selectedCategoryId,
      categorySlug: state.selectedCategorySlug,
      latitude: state.latitude,
      longitude: state.longitude,
      minRating: state.minRating,
      sortBy: state.sortBy,
      page: 1,
      limit: AppConstants.searchResultsPageSize,
    );

    result.when(
      success: (page) {
        state = state.copyWith(
          providers: page.providers,
          isLoading: false,
          hasMore: page.hasMore,
          currentPage: 1,
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          providers: [],
        );
      },
    );
  }

  /// Carga la siguiente pagina de resultados.
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;

    final result = await _repository.searchProviders(
      query: state.searchQuery,
      categoryId: state.selectedCategoryId,
      categorySlug: state.selectedCategorySlug,
      latitude: state.latitude,
      longitude: state.longitude,
      minRating: state.minRating,
      sortBy: state.sortBy,
      page: nextPage,
      limit: AppConstants.searchResultsPageSize,
    );

    result.when(
      success: (page) {
        state = state.copyWith(
          providers: [...state.providers, ...page.providers],
          isLoadingMore: false,
          hasMore: page.hasMore,
          currentPage: nextPage,
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isLoadingMore: false,
          errorMessage: failure.message,
        );
      },
    );
  }

  /// Actualiza el texto de busqueda y lanza busqueda.
  void setSearchQuery(String? query) {
    if (query == state.searchQuery) return;
    state = state.copyWith(
      searchQuery: query,
      clearQuery: query == null || query.isEmpty,
    );
    search();
  }

  /// Selecciona una categoria por ID.
  void setCategoryById(String? categoryId) {
    if (categoryId == state.selectedCategoryId) {
      // Deseleccionar si ya esta activa
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(
        selectedCategoryId: categoryId,
        clearCategory: categoryId == null,
      );
    }
    search();
  }

  /// Selecciona una categoria por slug.
  void setCategoryBySlug(String? slug) {
    if (slug == state.selectedCategorySlug) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(
        selectedCategorySlug: slug,
        clearCategory: slug == null,
      );
    }
    search();
  }

  /// Aplica rating minimo como filtro.
  void setMinRating(double? rating) {
    state = state.copyWith(
      minRating: rating,
      clearMinRating: rating == null,
    );
    search();
  }

  /// Cambia el criterio de ordenamiento.
  void setSortBy(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
    search();
  }

  /// Establece las coordenadas del usuario.
  void setLocation(double? latitude, double? longitude) {
    state = state.copyWith(latitude: latitude, longitude: longitude);
  }

  /// Limpia todos los filtros y vuelve a buscar.
  void clearFilters() {
    state = const ProviderSearchState();
    search();
  }

  /// Refresca los resultados manteniendo los filtros actuales.
  Future<void> refresh() async {
    await search();
  }
}

// ── Categories State ────────────────────────────

class CategoriesState {
  final List<ServiceCategory> categories;
  final bool isLoading;
  final String? errorMessage;

  const CategoriesState({
    this.categories = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  CategoriesState copyWith({
    List<ServiceCategory>? categories,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CategoriesState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class CategoriesNotifier extends StateNotifier<CategoriesState> {
  final ProviderSearchRepository _repository;

  CategoriesNotifier(this._repository) : super(const CategoriesState());

  Future<void> loadCategories() async {
    if (state.categories.isNotEmpty) return; // Ya cargadas

    state = state.copyWith(isLoading: true);

    final result = await _repository.getCategories();

    result.when(
      success: (categories) {
        state = CategoriesState(categories: categories);
      },
      failure: (failure) {
        state = CategoriesState(errorMessage: failure.message);
      },
    );
  }
}

// ── Riverpod Providers ──────────────────────────

final providerSearchProvider =
    StateNotifierProvider<ProviderSearchNotifier, ProviderSearchState>((ref) {
  return ProviderSearchNotifier(ref.read(providerSearchRepositoryProvider));
});

final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, CategoriesState>((ref) {
  return CategoriesNotifier(ref.read(providerSearchRepositoryProvider));
});
