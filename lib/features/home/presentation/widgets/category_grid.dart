import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_router.dart';
import 'category_card.dart';

class CategoryItem {
  final String name;
  final String slug;
  final IconData icon;
  final Color color;

  const CategoryItem({
    required this.name,
    required this.slug,
    required this.icon,
    required this.color,
  });
}

const _categories = [
  CategoryItem(
    name: 'Plomería',
    slug: 'plomeria',
    icon: Icons.plumbing,
    color: Color(0xFF2196F3),
  ),
  CategoryItem(
    name: 'Electricidad',
    slug: 'electricidad',
    icon: Icons.electrical_services,
    color: Color(0xFFF59E0B),
  ),
  CategoryItem(
    name: 'Cerrajería',
    slug: 'cerrajeria',
    icon: Icons.lock,
    color: Color(0xFF6B7280),
  ),
  CategoryItem(
    name: 'Pintura',
    slug: 'pintura',
    icon: Icons.format_paint,
    color: Color(0xFFEC4899),
  ),
  CategoryItem(
    name: 'Limpieza',
    slug: 'limpieza',
    icon: Icons.cleaning_services,
    color: Color(0xFF10B981),
  ),
  CategoryItem(
    name: 'Jardinería',
    slug: 'jardineria',
    icon: Icons.yard,
    color: Color(0xFF22C55E),
  ),
  CategoryItem(
    name: 'Carpintería',
    slug: 'carpinteria',
    icon: Icons.carpenter,
    color: Color(0xFF92400E),
  ),
  CategoryItem(
    name: 'Aire Acond.',
    slug: 'aire_acondicionado',
    icon: Icons.ac_unit,
    color: Color(0xFF06B6D4),
  ),
  CategoryItem(
    name: 'Electro-\ndomesticos',
    slug: 'electrodomesticos',
    icon: Icons.kitchen,
    color: Color(0xFF8B5CF6),
  ),
  CategoryItem(
    name: 'Mudanzas',
    slug: 'mudanzas',
    icon: Icons.local_shipping,
    color: Color(0xFFEF4444),
  ),
  CategoryItem(
    name: 'Albañilería',
    slug: 'albanileria',
    icon: Icons.construction,
    color: Color(0xFF78716C),
  ),
  CategoryItem(
    name: 'Vidriería',
    slug: 'vidrieria',
    icon: Icons.window,
    color: Color(0xFF0EA5E9),
  ),
  CategoryItem(
    name: 'Fumigación',
    slug: 'fumigacion',
    icon: Icons.pest_control,
    color: Color(0xFF84CC16),
  ),
  CategoryItem(
    name: 'Otros',
    slug: 'otros',
    icon: Icons.more_horiz,
    color: Color(0xFF9CA3AF),
  ),
];

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return CategoryCard(
          name: category.name,
          icon: category.icon,
          color: category.color,
          onTap: () {
            context.push(
              '${AppRoutes.providerSearch}?category=${category.slug}',
            );
          },
        );
      },
    );
  }
}
