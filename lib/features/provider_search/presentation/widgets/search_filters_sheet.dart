import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_theme.dart';
import '../providers/provider_search_provider.dart';

/// Bottom sheet con opciones de filtro para la busqueda de proveedores.
/// Permite configurar: calificacion minima, ordenamiento.
class SearchFiltersSheet extends ConsumerStatefulWidget {
  const SearchFiltersSheet({super.key});

  @override
  ConsumerState<SearchFiltersSheet> createState() => _SearchFiltersSheetState();

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SearchFiltersSheet(),
    );
  }
}

class _SearchFiltersSheetState extends ConsumerState<SearchFiltersSheet> {
  late double? _minRating;
  late String _sortBy;

  @override
  void initState() {
    super.initState();
    final state = ref.read(providerSearchProvider);
    _minRating = state.minRating;
    _sortBy = state.sortBy;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.textHint.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text(
                    'Filtros',
                    style: textTheme.headlineSmall?.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _minRating = null;
                        _sortBy = 'rating';
                      });
                    },
                    child: Text(
                      'Limpiar',
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Ordenar por
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ordenar por',
                    style: textTheme.titleMedium?.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _SortOption(
                        label: 'Mejor calificados',
                        icon: Icons.star,
                        value: 'rating',
                        selected: _sortBy,
                        onTap: () => setState(() => _sortBy = 'rating'),
                      ),
                      _SortOption(
                        label: 'Mas resenas',
                        icon: Icons.rate_review_outlined,
                        value: 'reviews',
                        selected: _sortBy,
                        onTap: () => setState(() => _sortBy = 'reviews'),
                      ),
                      _SortOption(
                        label: 'Mas cercanos',
                        icon: Icons.near_me,
                        value: 'distance',
                        selected: _sortBy,
                        onTap: () => setState(() => _sortBy = 'distance'),
                      ),
                      _SortOption(
                        label: 'Menor precio',
                        icon: Icons.attach_money,
                        value: 'price',
                        selected: _sortBy,
                        onTap: () => setState(() => _sortBy = 'price'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            const Divider(),

            // Calificacion minima
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calificacion minima',
                    style: textTheme.titleMedium?.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(5, (index) {
                      final rating = (index + 1).toDouble();
                      final isSelected =
                          _minRating != null && _minRating! <= rating;
                      final isExact = _minRating == rating;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _minRating = isExact ? null : rating;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isExact
                                ? colors.warning.withOpacity(0.15)
                                : colors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                            border: isExact
                                ? Border.all(
                                    color: colors.warning,
                                    width: 1.5,
                                  )
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 20,
                                color: isSelected
                                    ? colors.warning
                                    : colors.textHint,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${rating.toInt()}+',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isExact
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isExact
                                      ? colors.warning
                                      : colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Boton aplicar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text(
                    'Aplicar filtros',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyFilters() {
    final notifier = ref.read(providerSearchProvider.notifier);

    notifier.setMinRating(_minRating);
    notifier.setSortBy(_sortBy);

    Navigator.of(context).pop();
  }
}

class _SortOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final String selected;
  final VoidCallback onTap;

  const _SortOption({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isSelected = value == selected;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withOpacity(0.1)
              : colors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: colors.primary, width: 1.5)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? colors.primary : colors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? colors.primary : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
