import '../../../../core/api/api_client.dart';
import '../models/provider_search_result_model.dart';
import '../models/service_category_model.dart';

/// Datasource remoto para busqueda de proveedores.
/// Se comunica con el endpoint GET /providers/search.
class ProviderSearchRemoteDatasource {
  final ApiClient _apiClient;

  ProviderSearchRemoteDatasource(this._apiClient);

  /// Busca proveedores con filtros y paginacion.
  Future<ProviderSearchPageResponse> searchProviders({
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
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      'sortBy': sortBy,
    };

    if (query != null && query.trim().isNotEmpty) {
      queryParams['query'] = query.trim();
    }
    if (categoryId != null) {
      queryParams['categoryId'] = categoryId;
    }
    if (categorySlug != null) {
      queryParams['categorySlug'] = categorySlug;
    }
    if (latitude != null) {
      queryParams['latitude'] = latitude;
    }
    if (longitude != null) {
      queryParams['longitude'] = longitude;
    }
    if (radiusKm != null) {
      queryParams['radiusKm'] = radiusKm;
    }
    if (minRating != null) {
      queryParams['minRating'] = minRating;
    }

    final response = await _apiClient.get(
      '/providers/search',
      queryParameters: queryParams,
    );

    final responseData = response.data as Map<String, dynamic>;
    final dataList = responseData['data'] as List<dynamic>? ?? [];
    final meta = responseData['meta'] as Map<String, dynamic>? ?? {};

    final providers = dataList
        .map(
          (json) => ProviderSearchResultModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();

    return ProviderSearchPageResponse(
      providers: providers,
      total: meta['total'] as int? ?? 0,
      page: meta['page'] as int? ?? page,
      limit: meta['limit'] as int? ?? limit,
      totalPages: meta['totalPages'] as int? ?? 0,
    );
  }

  /// Obtiene las categorias de servicio desde el backend.
  Future<List<ServiceCategoryModel>> getCategories() async {
    final response = await _apiClient.get('/services/categories');

    final data = response.data;
    List<dynamic> items;

    if (data is List<dynamic>) {
      items = data;
    } else if (data is Map<String, dynamic> && data.containsKey('data')) {
      items = data['data'] as List<dynamic>;
    } else {
      items = [];
    }

    return items
        .map(
          (json) =>
              ServiceCategoryModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }
}

/// Respuesta paginada del datasource.
class ProviderSearchPageResponse {
  final List<ProviderSearchResultModel> providers;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const ProviderSearchPageResponse({
    required this.providers,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });
}
