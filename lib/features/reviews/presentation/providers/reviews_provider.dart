import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/datasources/reviews_remote_datasource.dart';
import '../../data/repositories/reviews_repository_impl.dart';
import '../../domain/entities/review.dart';
import '../../domain/entities/review_stats.dart';
import '../../domain/repositories/reviews_repository.dart';

// ── Dependency Injection ────────────────────────

final reviewsRemoteDatasourceProvider =
    Provider<ReviewsRemoteDatasource>((ref) {
  return ReviewsRemoteDatasource(ref.read(apiClientProvider));
});

final reviewsRepositoryProvider = Provider<ReviewsRepository>((ref) {
  return ReviewsRepositoryImpl(ref.read(reviewsRemoteDatasourceProvider));
});

// ── Provider Reviews State ──────────────────────

class ProviderReviewsState {
  final List<Review> reviews;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? errorMessage;

  const ProviderReviewsState({
    this.reviews = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.errorMessage,
  });

  ProviderReviewsState copyWith({
    List<Review>? reviews,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? errorMessage,
  }) {
    return ProviderReviewsState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage,
    );
  }
}

// ── Provider Reviews Notifier ───────────────────

class ProviderReviewsNotifier extends StateNotifier<ProviderReviewsState> {
  final ReviewsRepository _repository;
  final String _providerId;

  ProviderReviewsNotifier(this._repository, this._providerId)
      : super(const ProviderReviewsState());

  /// Carga la primera pagina de resenas.
  Future<void> loadReviews() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentPage: 1,
    );

    final result = await _repository.getProviderReviews(
      providerId: _providerId,
      page: 1,
      limit: AppConstants.reviewsPageSize,
    );

    result.when(
      success: (reviews) {
        state = ProviderReviewsState(
          reviews: reviews,
          isLoading: false,
          hasMore: reviews.length >= AppConstants.reviewsPageSize,
          currentPage: 1,
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
    );
  }

  /// Carga la siguiente pagina de resenas.
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);
    final nextPage = state.currentPage + 1;

    final result = await _repository.getProviderReviews(
      providerId: _providerId,
      page: nextPage,
      limit: AppConstants.reviewsPageSize,
    );

    result.when(
      success: (reviews) {
        state = state.copyWith(
          reviews: [...state.reviews, ...reviews],
          isLoading: false,
          hasMore: reviews.length >= AppConstants.reviewsPageSize,
          currentPage: nextPage,
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
    );
  }
}

// ── Create Review State ─────────────────────────

class CreateReviewState {
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;

  const CreateReviewState({
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  CreateReviewState copyWith({
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return CreateReviewState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
    );
  }
}

class CreateReviewNotifier extends StateNotifier<CreateReviewState> {
  final ReviewsRepository _repository;

  CreateReviewNotifier(this._repository) : super(const CreateReviewState());

  Future<bool> submitReview({
    required String bookingId,
    required int rating,
    required String comment,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      isSuccess: false,
    );

    final result = await _repository.createReview(
      bookingId: bookingId,
      rating: rating,
      comment: comment,
    );

    return result.when(
      success: (_) {
        state = const CreateReviewState(isSuccess: true);
        return true;
      },
      failure: (failure) {
        state = CreateReviewState(errorMessage: failure.message);
        return false;
      },
    );
  }

  void reset() {
    state = const CreateReviewState();
  }
}

// ── Riverpod Providers ──────────────────────────

/// Provider family para las resenas de un proveedor especifico.
final providerReviewsProvider = StateNotifierProvider.family<
    ProviderReviewsNotifier, ProviderReviewsState, String>(
  (ref, providerId) {
    return ProviderReviewsNotifier(
      ref.read(reviewsRepositoryProvider),
      providerId,
    );
  },
);

/// Provider family para las estadisticas de un proveedor especifico.
final providerStatsProvider =
    FutureProvider.family<ReviewStats, String>((ref, providerId) async {
  final repository = ref.read(reviewsRepositoryProvider);
  final result = await repository.getProviderStats(providerId);
  return result.when(
    success: (stats) => stats,
    failure: (failure) => throw Exception(failure.message),
  );
});

/// Provider para crear resenas.
final createReviewProvider =
    StateNotifierProvider<CreateReviewNotifier, CreateReviewState>((ref) {
  return CreateReviewNotifier(ref.read(reviewsRepositoryProvider));
});

/// Provider para las resenas del usuario autenticado.
final myReviewsProvider = FutureProvider<List<Review>>((ref) async {
  final repository = ref.read(reviewsRepositoryProvider);
  final result = await repository.getMyReviews();
  return result.when(
    success: (reviews) => reviews,
    failure: (failure) => throw Exception(failure.message),
  );
});
