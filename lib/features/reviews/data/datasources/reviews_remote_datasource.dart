import '../../../../core/api/api_client.dart';
import '../models/review_model.dart';
import '../models/review_stats_model.dart';

class ReviewsRemoteDatasource {
  final ApiClient _apiClient;

  ReviewsRemoteDatasource(this._apiClient);

  /// Crea una resena para un servicio completado.
  Future<ReviewModel> createReview({
    required String bookingId,
    required int rating,
    required String comment,
  }) async {
    final response = await _apiClient.post(
      '/reviews',
      data: {
        'bookingId': bookingId,
        'rating': rating,
        'comment': comment,
      },
    );
    return ReviewModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Obtiene las resenas de un proveedor con paginacion.
  Future<List<ReviewModel>> getProviderReviews({
    required String providerId,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _apiClient.get(
      '/reviews/provider/$providerId',
      queryParameters: {'page': page, 'limit': limit},
    );

    final data = response.data;
    List<dynamic> items;

    if (data is Map<String, dynamic> && data.containsKey('data')) {
      items = data['data'] as List<dynamic>;
    } else if (data is List<dynamic>) {
      items = data;
    } else {
      items = [];
    }

    return items
        .map((json) => ReviewModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Obtiene las estadisticas de resenas de un proveedor.
  Future<ReviewStatsModel> getProviderStats(String providerId) async {
    final response = await _apiClient.get(
      '/reviews/provider/$providerId/stats',
    );
    return ReviewStatsModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Obtiene las resenas del usuario autenticado.
  Future<List<ReviewModel>> getMyReviews() async {
    final response = await _apiClient.get('/reviews/me');

    final data = response.data;
    List<dynamic> items;

    if (data is Map<String, dynamic> && data.containsKey('data')) {
      items = data['data'] as List<dynamic>;
    } else if (data is List<dynamic>) {
      items = data;
    } else {
      items = [];
    }

    return items
        .map((json) => ReviewModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
