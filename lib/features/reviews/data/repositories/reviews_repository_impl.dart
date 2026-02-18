import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/review.dart';
import '../../domain/entities/review_stats.dart';
import '../../domain/repositories/reviews_repository.dart';
import '../datasources/reviews_remote_datasource.dart';

class ReviewsRepositoryImpl implements ReviewsRepository {
  final ReviewsRemoteDatasource _datasource;

  ReviewsRepositoryImpl(this._datasource);

  @override
  Future<Result<Review>> createReview({
    required String bookingId,
    required int rating,
    required String comment,
  }) async {
    try {
      final review = await _datasource.createReview(
        bookingId: bookingId,
        rating: rating,
        comment: comment,
      );
      return Result.success(review);
    } on AppException catch (e) {
      return Result.failure(Failure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<Review>>> getProviderReviews({
    required String providerId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final reviews = await _datasource.getProviderReviews(
        providerId: providerId,
        page: page,
        limit: limit,
      );
      return Result.success(reviews);
    } on AppException catch (e) {
      return Result.failure(Failure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<ReviewStats>> getProviderStats(String providerId) async {
    try {
      final stats = await _datasource.getProviderStats(providerId);
      return Result.success(stats);
    } on AppException catch (e) {
      return Result.failure(Failure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<Review>>> getMyReviews() async {
    try {
      final reviews = await _datasource.getMyReviews();
      return Result.success(reviews);
    } on AppException catch (e) {
      return Result.failure(Failure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Result.failure(
        Failure(message: 'Error inesperado: ${e.toString()}'),
      );
    }
  }
}
