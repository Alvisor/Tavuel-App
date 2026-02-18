import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/review_stats.dart';
import 'star_rating_display.dart';

/// Widget estilo Google Play Store que muestra un resumen de calificaciones.
/// Gran numero promedio con estrellas, barras horizontales de distribucion,
/// y conteo total de resenas.
class RatingSummaryWidget extends StatelessWidget {
  final ReviewStats stats;

  const RatingSummaryWidget({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.surfaceVariant),
        boxShadow: [
          BoxShadow(
            color: colors.onBackground.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Lado izquierdo: numero grande + estrellas + total
          SizedBox(
            width: 100,
            child: Column(
              children: [
                Text(
                  stats.averageRating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                StarRatingDisplay(
                  rating: stats.averageRating,
                  starSize: 16,
                  showNumber: false,
                  showCount: false,
                ),
                const SizedBox(height: 6),
                Text(
                  '${stats.totalReviews} resenas',
                  style: TextStyle(
                    color: colors.textHint,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),

          // Lado derecho: barras de distribucion
          Expanded(
            child: Column(
              children: List.generate(5, (index) {
                final stars = 5 - index;
                final percentage = stats.percentageFor(stars);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      // Numero de estrellas
                      SizedBox(
                        width: 14,
                        child: Text(
                          '$stars',
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: colors.textHint,
                      ),
                      const SizedBox(width: 8),

                      // Barra de progreso
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor:
                                colors.surfaceVariant,
                            color: _getBarColor(stars, colors),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Porcentaje
                      SizedBox(
                        width: 38,
                        child: Text(
                          '${percentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textHint,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBarColor(int stars, AppColorsExtension colors) {
    switch (stars) {
      case 5:
        return colors.success;
      case 4:
        return colors.statusCompleted;
      case 3:
        return colors.warning;
      case 2:
        return colors.secondary;
      case 1:
        return colors.error;
      default:
        return colors.textHint;
    }
  }
}
