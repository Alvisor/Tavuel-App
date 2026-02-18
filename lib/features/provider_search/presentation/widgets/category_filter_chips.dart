import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/service_category.dart';
import '../providers/provider_search_provider.dart';

/// Chips horizontales para filtrar por categoria de servicio.
class CategoryFilterChips extends ConsumerWidget {
  const CategoryFilterChips({super.key});

  /// Iconos asociados a cada slug de categoria.
  static const Map<String, IconData> _categoryIcons = {
    'plomeria': Icons.plumbing,
    'electricidad': Icons.electrical_services,
    'cerrajeria': Icons.lock_outline,
    'pintura': Icons.format_paint,
    'limpieza': Icons.cleaning_services,
    'jardineria': Icons.grass,
    'carpinteria': Icons.carpenter,
    'aire_acondicionado': Icons.ac_unit,
    'electrodomesticos': Icons.kitchen,
    'mudanzas': Icons.local_shipping,
    'albanileria': Icons.construction,
    'vidrieria': Icons.window,
    'fumigacion': Icons.bug_report,
    'otros': Icons.miscellaneous_services,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoriesProvider);
    final searchState = ref.watch(providerSearchProvider);

    if (categoriesState.isLoading) {
      return const SizedBox(
        height: 44,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (categoriesState.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categoriesState.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categoriesState.categories[index];
          final isSelected =
              searchState.selectedCategoryId == category.id;
          return _CategoryChip(
            category: category,
            isSelected: isSelected,
            icon: _categoryIcons[category.slug],
            onTap: () {
              ref
                  .read(providerSearchProvider.notifier)
                  .setCategoryById(isSelected ? null : category.id);
            },
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final ServiceCategory category;
  final bool isSelected;
  final IconData? icon;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.isSelected,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary
              : colors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? colors.primary
                : colors.textHint.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.primary.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? colors.textOnPrimary
                    : colors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              category.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? colors.textOnPrimary
                    : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
