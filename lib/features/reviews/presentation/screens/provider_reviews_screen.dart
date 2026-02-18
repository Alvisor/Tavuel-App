import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../providers/reviews_provider.dart';
import '../widgets/rating_summary_widget.dart';
import '../widgets/review_card.dart';

class ProviderReviewsScreen extends ConsumerStatefulWidget {
  final String providerId;

  const ProviderReviewsScreen({super.key, required this.providerId});

  @override
  ConsumerState<ProviderReviewsScreen> createState() =>
      _ProviderReviewsScreenState();
}

class _ProviderReviewsScreenState
    extends ConsumerState<ProviderReviewsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(providerReviewsProvider(widget.providerId).notifier)
          .loadReviews();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(providerReviewsProvider(widget.providerId).notifier)
          .loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final reviewsState =
        ref.watch(providerReviewsProvider(widget.providerId));
    final statsAsync = ref.watch(providerStatsProvider(widget.providerId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resenas'),
        centerTitle: true,
        elevation: 0,
      ),
      body: reviewsState.isLoading && reviewsState.reviews.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : reviewsState.errorMessage != null && reviewsState.reviews.isEmpty
              ? _buildErrorState(reviewsState.errorMessage!, colors)
              : RefreshIndicator(
                  onRefresh: () async {
                    ref
                        .read(
                            providerReviewsProvider(widget.providerId).notifier)
                        .loadReviews();
                    ref.invalidate(providerStatsProvider(widget.providerId));
                  },
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      // Resumen de estadisticas
                      SliverToBoxAdapter(
                        child: statsAsync.when(
                          data: (stats) => Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: RatingSummaryWidget(stats: stats),
                          ),
                          loading: () => const Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ),

                      // Titulo de la seccion
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                          child: Row(
                            children: [
                              Text(
                                'Todas las resenas',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: colors.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${reviewsState.reviews.length} resenas',
                                style: TextStyle(
                                  color: colors.textHint,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Lista de resenas
                      if (reviewsState.reviews.isEmpty &&
                          !reviewsState.isLoading)
                        SliverToBoxAdapter(
                          child: _buildEmptyState(colors),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index < reviewsState.reviews.length) {
                                return ReviewCard(
                                  review: reviewsState.reviews[index],
                                );
                              }
                              // Indicador de carga al final
                              if (reviewsState.hasMore) {
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              return null;
                            },
                            childCount: reviewsState.reviews.length +
                                (reviewsState.hasMore ? 1 : 0),
                          ),
                        ),

                      // Espacio al final
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 24),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState(AppColorsExtension colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 64,
              color: colors.textHint.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Sin resenas aun',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Este proveedor aun no tiene resenas.',
              style: TextStyle(
                color: colors.textHint,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, AppColorsExtension colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colors.textHint),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(
                        providerReviewsProvider(widget.providerId).notifier)
                    .loadReviews();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.textOnPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
