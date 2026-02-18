import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/provider_search_result.dart';

/// Tarjeta que muestra un proveedor en los resultados de busqueda.
/// Incluye avatar, nombre, calificacion, categorias, precio y distancia.
class ProviderSearchCard extends StatelessWidget {
  final ProviderSearchResult provider;
  final VoidCallback onTap;

  const ProviderSearchCard({
    super.key,
    required this.provider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.onBackground.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              _buildAvatar(colors),
              const SizedBox(width: 14),
              // Contenido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre y distancia
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            provider.fullName,
                            style: textTheme.titleMedium?.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (provider.distanceText != null) ...[
                          const SizedBox(width: 8),
                          _buildDistanceBadge(colors, textTheme),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Rating
                    _buildRatingRow(colors, textTheme),
                    const SizedBox(height: 8),
                    // Categorias
                    if (provider.categories.isNotEmpty)
                      _buildCategoryChips(colors),
                    if (provider.categories.isNotEmpty)
                      const SizedBox(height: 8),
                    // Precio
                    if (provider.priceRangeText != null)
                      _buildPriceRow(colors, textTheme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(AppColorsExtension colors) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.primary.withOpacity(0.1),
      ),
      child: provider.avatarUrl != null && provider.avatarUrl!.isNotEmpty
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: provider.avatarUrl!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: Text(
                    provider.initials,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Center(
                  child: Text(
                    provider.initials,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                provider.initials,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
            ),
    );
  }

  Widget _buildDistanceBadge(
    AppColorsExtension colors,
    TextTheme textTheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 13,
            color: colors.info,
          ),
          const SizedBox(width: 2),
          Text(
            provider.distanceText!,
            style: textTheme.labelSmall?.copyWith(
              color: colors.info,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingRow(AppColorsExtension colors, TextTheme textTheme) {
    return Row(
      children: [
        // Estrellas
        ...List.generate(5, (index) {
          final starValue = index + 1;
          if (provider.rating >= starValue) {
            return Icon(Icons.star, size: 16, color: colors.warning);
          } else if (provider.rating >= starValue - 0.5) {
            return Icon(Icons.star_half, size: 16, color: colors.warning);
          } else {
            return Icon(
              Icons.star_border,
              size: 16,
              color: colors.textHint.withOpacity(0.4),
            );
          }
        }),
        const SizedBox(width: 6),
        Text(
          provider.rating.toStringAsFixed(1),
          style: textTheme.bodySmall?.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '(${provider.totalReviews})',
          style: textTheme.bodySmall?.copyWith(
            color: colors.textHint,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips(AppColorsExtension colors) {
    // Mostrar maximo 3 categorias
    final displayCategories = provider.categories.take(3).toList();
    final remaining = provider.categories.length - 3;

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        ...displayCategories.map(
          (cat) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              cat.name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: colors.primary,
              ),
            ),
          ),
        ),
        if (remaining > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+$remaining',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPriceRow(AppColorsExtension colors, TextTheme textTheme) {
    return Row(
      children: [
        Icon(
          Icons.attach_money,
          size: 16,
          color: colors.success,
        ),
        const SizedBox(width: 2),
        Text(
          provider.priceRangeText!,
          style: textTheme.bodySmall?.copyWith(
            color: colors.success,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
