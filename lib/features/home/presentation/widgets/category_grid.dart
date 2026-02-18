import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_router.dart';
import '../../../../app/theme/app_theme.dart';
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
    name: 'Todero',
    slug: 'todero',
    icon: Icons.handyman,
    color: Color(0xFF8B5CF6),
  ),
  CategoryItem(
    name: 'Pintura',
    slug: 'pintura',
    icon: Icons.format_paint,
    color: Color(0xFFEC4899),
  ),
  CategoryItem(
    name: 'Aseo',
    slug: 'aseo-del-hogar',
    icon: Icons.cleaning_services,
    color: Color(0xFF10B981),
  ),
  CategoryItem(
    name: 'Cerrajería',
    slug: 'cerrajeria',
    icon: Icons.lock,
    color: Color(0xFF6B7280),
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
    name: 'Mudanzas',
    slug: 'mudanzas',
    icon: Icons.local_shipping,
    color: Color(0xFFEF4444),
  ),
  CategoryItem(
    name: 'Fumigación',
    slug: 'fumigacion',
    icon: Icons.pest_control,
    color: Color(0xFF84CC16),
  ),
  CategoryItem(
    name: 'Albañilería',
    slug: 'albanileria',
    icon: Icons.construction,
    color: Color(0xFF78716C),
  ),
];

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    // Mostrar las primeras 4 como destacadas en scroll horizontal
    final featured = _categories.take(4).toList();
    final rest = _categories.skip(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Categorías destacadas - scroll horizontal
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: featured.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final cat = featured[index];
              return SizedBox(
                width: 90,
                child: _FeaturedCategoryCard(
                  name: cat.name,
                  icon: cat.icon,
                  color: cat.color,
                  onTap: () => context.push(
                    '${AppRoutes.providerSearch}?category=${cat.slug}',
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // Resto en grid de 4 columnas compacto
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Más servicios',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => context.push(AppRoutes.providerSearch),
                child: Text(
                  'Ver todos',
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.78,
          ),
          itemCount: rest.length,
          itemBuilder: (context, index) {
            final cat = rest[index];
            return CategoryCard(
              name: cat.name,
              icon: cat.icon,
              color: cat.color,
              onTap: () => context.push(
                '${AppRoutes.providerSearch}?category=${cat.slug}',
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Card destacada para las categorías principales.
class _FeaturedCategoryCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FeaturedCategoryCard({
    required this.name,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.12),
                color.withOpacity(0.04),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
