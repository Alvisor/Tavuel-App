import '../../../../core/errors/failure.dart';
import '../entities/provider_search_result.dart';
import '../entities/service_category.dart';

/// Contrato para el repositorio de busqueda de proveedores.
abstract class ProviderSearchRepository {
  /// Busca proveedores con filtros y paginacion.
  Future<Result<ProviderSearchPage>> searchProviders({
    String? query,
    String? categoryId,
    String? categorySlug,
    double? latitude,
    double? longitude,
    double? radiusKm,
    double? minRating,
    String sortBy = 'rating',
    int page = 1,
    int limit = 15,
  });

  /// Obtiene las categorias de servicio disponibles.
  Future<Result<List<ServiceCategory>>> getCategories();
}

/// Pagina de resultados de busqueda con metadatos de paginacion.
class ProviderSearchPage {
  final List<ProviderSearchResult> providers;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const ProviderSearchPage({
    required this.providers,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;
}
