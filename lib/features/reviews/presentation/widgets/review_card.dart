import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/review.dart';
import 'star_rating_display.dart';

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.surfaceVariant),
        boxShadow: [
          BoxShadow(
            color: colors.onBackground.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera: avatar, nombre, fecha
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: colors.primary.withOpacity(0.1),
                backgroundImage: review.clientAvatarUrl != null &&
                        review.clientAvatarUrl!.isNotEmpty
                    ? CachedNetworkImageProvider(review.clientAvatarUrl!)
                    : null,
                child: review.clientAvatarUrl == null ||
                        review.clientAvatarUrl!.isEmpty
                    ? Text(
                        _getInitial(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                          fontSize: 16,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Nombre y fecha
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.clientName ?? 'Usuario',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(review.createdAt),
                      style: TextStyle(
                        color: colors.textHint,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Estrellas
          StarRatingDisplay(
            rating: review.rating.toDouble(),
            starSize: 18,
            showNumber: false,
            showCount: false,
          ),
          const SizedBox(height: 10),

          // Comentario
          Text(
            review.comment,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _getInitial() {
    if (review.clientName != null && review.clientName!.isNotEmpty) {
      return review.clientName![0].toUpperCase();
    }
    return 'U';
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'es').format(date);
  }
}
