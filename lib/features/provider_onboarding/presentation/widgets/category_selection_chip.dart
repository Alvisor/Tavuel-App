import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../domain/entities/service_category.dart';

/// Card de selección para una categoría de servicio en el onboarding.
///
/// Muestra nombre, descripción, icono y cantidad de servicios.
/// Estado seleccionado con borde y fondo destacado.
class CategorySelectionChip extends StatelessWidget {
  final ServiceCategory category;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const CategorySelectionChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onSelected,
  });

  static const _iconMap = <String, IconData>{
    'limpieza': Icons.cleaning_services,
    'aseo-del-hogar': Icons.cleaning_services,
    'plomeria': Icons.plumbing,
    'electricidad': Icons.electrical_services,
    'carpinteria': Icons.carpenter,
    'pintura': Icons.format_paint,
    'jardineria': Icons.yard,
    'cerrajeria': Icons.lock,
    'fumigacion': Icons.pest_control,
    'mudanzas': Icons.local_shipping,
    'aire-acondicionado': Icons.ac_unit,
    'reparaciones': Icons.build,
    'tecnologia': Icons.computer,
    'belleza': Icons.spa,
    'mascotas': Icons.pets,
    'cocina': Icons.restaurant,
    'lavanderia': Icons.local_laundry_service,
    'todero': Icons.handyman,
    'albanileria': Icons.construction,
    'vidrieria': Icons.window,
    'electrodomesticos': Icons.kitchen,
  };

  static const _colorMap = <String, Color>{
    'plomeria': Color(0xFF2196F3),
    'electricidad': Color(0xFFF59E0B),
    'cerrajeria': Color(0xFF6B7280),
    'pintura': Color(0xFFEC4899),
    'limpieza': Color(0xFF10B981),
    'aseo-del-hogar': Color(0xFF10B981),
    'jardineria': Color(0xFF22C55E),
    'carpinteria': Color(0xFF92400E),
    'aire-acondicionado': Color(0xFF06B6D4),
    'todero': Color(0xFF8B5CF6),
    'mudanzas': Color(0xFFEF4444),
    'albanileria': Color(0xFF78716C),
    'fumigacion': Color(0xFF84CC16),
    'tecnologia': Color(0xFF3B82F6),
  };

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final icon = _iconMap[category.slug] ?? Icons.miscellaneous_services;
    final accentColor = _colorMap[category.slug] ?? colors.primary;

    return GestureDetector(
      onTap: () => onSelected(!isSelected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withOpacity(0.08)
              : colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor : colors.surfaceVariant,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono con fondo circular
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? accentColor.withOpacity(0.15)
                      : colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? accentColor : colors.textSecondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              // Nombre + descripción
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? accentColor : colors.textPrimary,
                      ),
                    ),
                    if (category.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        category.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (category.serviceCount > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${category.serviceCount} servicio${category.serviceCount != 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: colors.textHint,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Check indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isSelected ? accentColor : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? accentColor : colors.textHint.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
