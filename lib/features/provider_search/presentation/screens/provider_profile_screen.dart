import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../reviews/presentation/providers/reviews_provider.dart';
import '../../../reviews/presentation/widgets/rating_summary_widget.dart';
import '../../../reviews/presentation/widgets/review_card.dart';
import '../../../reviews/presentation/widgets/star_rating_display.dart';

/// Pantalla publica del perfil de un proveedor.
/// Muestra informacion del proveedor, resenas y permite solicitar un servicio.
class ProviderProfileScreen extends ConsumerStatefulWidget {
  final String providerId;
  final String? providerName;
  final String? providerAvatarUrl;
  final double? providerRating;
  final String? providerBio;
  final bool? isVerified;
  final List<String>? categories;

  const ProviderProfileScreen({
    super.key,
    required this.providerId,
    this.providerName,
    this.providerAvatarUrl,
    this.providerRating,
    this.providerBio,
    this.isVerified,
    this.categories,
  });

  @override
  ConsumerState<ProviderProfileScreen> createState() =>
      _ProviderProfileScreenState();
}

class _ProviderProfileScreenState
    extends ConsumerState<ProviderProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(providerReviewsProvider(widget.providerId).notifier)
          .loadReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final reviewsState =
        ref.watch(providerReviewsProvider(widget.providerId));
    final statsAsync = ref.watch(providerStatsProvider(widget.providerId));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar con imagen
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: colors.primary,
            foregroundColor: colors.textOnPrimary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colors.primary,
                      colors.primaryDark,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Avatar
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor:
                                colors.textOnPrimary.withOpacity(0.2),
                            backgroundImage:
                                widget.providerAvatarUrl != null &&
                                        widget.providerAvatarUrl!.isNotEmpty
                                    ? CachedNetworkImageProvider(
                                        widget.providerAvatarUrl!)
                                    : null,
                            child: widget.providerAvatarUrl == null ||
                                    widget.providerAvatarUrl!.isEmpty
                                ? Text(
                                    _getInitials(),
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: colors.textOnPrimary,
                                    ),
                                  )
                                : null,
                          ),
                          if (widget.isVerified == true)
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.verified,
                                color: colors.primary,
                                size: 22,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Nombre
                      Text(
                        widget.providerName ?? 'Proveedor',
                        style: TextStyle(
                          color: colors.textOnPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Rating
                      StarRatingDisplay(
                        rating: widget.providerRating ?? 0,
                        starSize: 20,
                        activeColor: colors.secondary,
                        inactiveColor:
                            colors.textOnPrimary.withOpacity(0.4),
                        showCount: true,
                        reviewCount: statsAsync.when(
                          data: (stats) => stats.totalReviews,
                          loading: () => null,
                          error: (_, __) => null,
                        ),
                        numberStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colors.textOnPrimary,
                          fontSize: 16,
                        ),
                        countStyle: TextStyle(
                          color: colors.textOnPrimary.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Contenido
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bio
                if (widget.providerBio != null &&
                    widget.providerBio!.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Acerca de',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.providerBio!,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Categorias
                if (widget.categories != null &&
                    widget.categories!.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: Text(
                      'Servicios que ofrece',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.categories!.map((category) {
                        return Chip(
                          label: Text(
                            _formatCategory(category),
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.primary,
                            ),
                          ),
                          backgroundColor:
                              colors.primary.withOpacity(0.08),
                          side: BorderSide(
                            color: colors.primary.withOpacity(0.2),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Resumen de resenas
                statsAsync.when(
                  data: (stats) => stats.totalReviews > 0
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 0, 16, 8),
                              child: Text(
                                'Calificaciones y Resenas',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                            RatingSummaryWidget(stats: stats),
                          ],
                        )
                      : const SizedBox.shrink(),
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),

          // Resenas recientes (maximo 3)
          if (reviewsState.reviews.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    Text(
                      'Resenas recientes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    if (reviewsState.reviews.length > 3)
                      TextButton(
                        onPressed: () {
                          context.push(
                            '/provider/${widget.providerId}/reviews',
                          );
                        },
                        child: Text(
                          'Ver todas',
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= 3 || index >= reviewsState.reviews.length) {
                    return null;
                  }
                  return ReviewCard(review: reviewsState.reviews[index]);
                },
                childCount: reviewsState.reviews.length.clamp(0, 3),
              ),
            ),
            // Boton "Ver todas las resenas" si hay mas de 3
            if (reviewsState.reviews.length > 3 ||
                reviewsState.hasMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: OutlinedButton(
                    onPressed: () {
                      context.push(
                        '/provider/${widget.providerId}/reviews',
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.primary,
                      side: BorderSide(color: colors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Ver todas las resenas',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
          ],

          // Estado vacio de resenas
          if (reviewsState.reviews.isEmpty && !reviewsState.isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.rate_review_outlined,
                        size: 48,
                        color: colors.textHint.withOpacity(0.4),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Aun no tiene resenas',
                        style: TextStyle(
                          color: colors.textHint,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Espacio para el boton flotante
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),

      // Boton de solicitar servicio
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          boxShadow: [
            BoxShadow(
              color: colors.onBackground.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                context.push(
                  '/booking-create?providerId=${widget.providerId}',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.secondary,
                foregroundColor: colors.textOnSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Solicitar Servicio',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getInitials() {
    if (widget.providerName == null || widget.providerName!.isEmpty) {
      return 'P';
    }
    final parts = widget.providerName!.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  String _formatCategory(String category) {
    final formatted = category.replaceAll('_', ' ');
    if (formatted.isEmpty) return formatted;
    return formatted[0].toUpperCase() + formatted.substring(1).toLowerCase();
  }
}
