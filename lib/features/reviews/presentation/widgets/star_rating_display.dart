import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';

/// Widget de solo lectura que muestra estrellas llenas, medias y vacias.
/// Ejemplo: 4.2 (127)
class StarRatingDisplay extends StatelessWidget {
  final double rating;
  final int? reviewCount;
  final double starSize;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool showNumber;
  final bool showCount;
  final TextStyle? numberStyle;
  final TextStyle? countStyle;

  const StarRatingDisplay({
    super.key,
    required this.rating,
    this.reviewCount,
    this.starSize = 18,
    this.activeColor,
    this.inactiveColor,
    this.showNumber = true,
    this.showCount = true,
    this.numberStyle,
    this.countStyle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final active = activeColor ?? colors.secondary;
    final inactive = inactiveColor ?? colors.textHint.withOpacity(0.3);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Estrellas
        ...List.generate(5, (index) {
          final starNumber = index + 1;
          IconData icon;

          if (rating >= starNumber) {
            icon = Icons.star_rounded;
          } else if (rating >= starNumber - 0.5) {
            icon = Icons.star_half_rounded;
          } else {
            icon = Icons.star_outline_rounded;
          }

          return Icon(
            icon,
            size: starSize,
            color: rating >= starNumber - 0.5 ? active : inactive,
          );
        }),

        // Numero de rating
        if (showNumber) ...[
          const SizedBox(width: 6),
          Text(
            rating.toStringAsFixed(1),
            style: numberStyle ??
                TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: starSize * 0.8,
                  color: colors.textPrimary,
                ),
          ),
        ],

        // Conteo de resenas
        if (showCount && reviewCount != null) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: countStyle ??
                TextStyle(
                  fontSize: starSize * 0.7,
                  color: colors.textHint,
                ),
          ),
        ],
      ],
    );
  }
}
