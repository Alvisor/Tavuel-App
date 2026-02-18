import '../../../../core/errors/failure.dart';
import '../entities/review.dart';
import '../entities/review_stats.dart';

abstract class ReviewsRepository {
  /// Crea una resena para un servicio completado.
  Future<Result<Review>> createReview({
    required String bookingId,
    required int rating,
    required String comment,
  });

  /// Obtiene las resenas de un proveedor con paginacion.
  Future<Result<List<Review>>> getProviderReviews({
    required String providerId,
    int page = 1,
    int limit = 10,
  });

  /// Obtiene las estadisticas de resenas de un proveedor.
  Future<Result<ReviewStats>> getProviderStats(String providerId);

  /// Obtiene las resenas del usuario autenticado.
  Future<Result<List<Review>>> getMyReviews();
}
