import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/provider_search_result.dart';
import '../../domain/entities/service_category.dart';
import '../../domain/repositories/provider_search_repository.dart';
import '../datasources/provider_search_remote_datasource.dart';

class ProviderSearchRepositoryImpl implements ProviderSearchRepository {
  final ProviderSearchRemoteDatasource _datasource;

  ProviderSearchRepositoryImpl(this._datasource);

  @override
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
  }) async {
    try {
      final response = await _datasource.searchProviders(
        query: query,
        categoryId: categoryId,
        categorySlug: categorySlug,
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        minRating: minRating,
        sortBy: sortBy,
        page: page,
        limit: limit,
      );

      return Result.success(
        ProviderSearchPage(
          providers: response.providers,
          total: response.total,
          page: response.page,
          limit: response.limit,
          totalPages: response.totalPages,
        ),
      );
    } on AppException catch (e) {
      return Result.failure(
        Failure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<ServiceCategory>>> getCategories() async {
    try {
      final categories = await _datasource.getCategories();
      return Result.success(categories);
    } on AppException catch (e) {
      return Result.failure(
        Failure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }
}
